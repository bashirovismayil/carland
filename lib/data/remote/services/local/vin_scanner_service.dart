import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/constants/enums/enums.dart';

class VinScanResult {
  final bool isSuccess;
  final String? vin;
  final String? formattedVin;
  final ScannerError? error;
  final String? errorMessage;
  final double? confidence;

  const VinScanResult._({
    required this.isSuccess,
    this.vin,
    this.formattedVin,
    this.error,
    this.errorMessage,
    this.confidence,
  });

  factory VinScanResult.success(String vin, {double? confidence}) {
    return VinScanResult._(
      isSuccess: true,
      vin: vin,
      formattedVin: _formatVin(vin),
      confidence: confidence,
    );
  }

  factory VinScanResult.failure(ScannerError error, String message) {
    return VinScanResult._(
      isSuccess: false,
      error: error,
      errorMessage: message,
    );
  }

  static String _formatVin(String vin) {
    if (vin.length != 17) return vin;
    return '${vin.substring(0, 3)} ${vin.substring(3, 9)} ${vin.substring(9, 17)}';
  }
}

class VinScannerService {
  CameraController? _cameraController;
  TextRecognizer? _textRecognizer;
  List<CameraDescription>? _cameras;

  bool _isProcessing = false;
  bool _isDisposed = false;
  bool _isStreaming = false;

  void Function(VinScanResult)? onVinDetected;
  void Function(String)? onDebugText;

  final Map<String, int> _detectionCounts = {};
  static const int _requiredDetections = 3;
  static const int _maxBufferSize = 20;

  DateTime? _lastProcessTime;
  static const _processInterval = Duration(milliseconds: 300);

  CameraController? get cameraController => _cameraController;

  bool get isProcessing => _isProcessing;

  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  Future<VinScanResult?> initialize() async {
    if (_isDisposed) return null;

    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        return VinScanResult.failure(
          ScannerError.noCameraAvailable,
          'No camera found on this device',
        );
      }

      final backCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      await _setupCameraSettings();

      return null;
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} - ${e.description}');

      if (e.code == 'CameraAccessDenied') {
        return VinScanResult.failure(
          ScannerError.permissionDenied,
          'Camera permission denied',
        );
      }

      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        'Failed to initialize camera: ${e.description}',
      );
    } catch (e) {
      debugPrint('Init error: $e');
      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        'Failed to initialize camera',
      );
    }
  }

  Future<void> _setupCameraSettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode not supported: $e');
    }

    try {
      await _cameraController!.setExposureMode(ExposureMode.auto);
    } catch (e) {
      debugPrint('Exposure mode not supported: $e');
    }
  }

  Future<void> setFocusPoint(Offset point, Size previewSize) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final x = (point.dx / previewSize.width).clamp(0.0, 1.0);
      final y = (point.dy / previewSize.height).clamp(0.0, 1.0);

      await _cameraController!.setFocusPoint(Offset(x, y));
      await _cameraController!.setExposurePoint(Offset(x, y));
    } catch (e) {
      debugPrint('Set focus point error: $e');
    }
  }

  Future<void> startContinuousScanning(
      void Function(VinScanResult) onDetected) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isStreaming) return;

    onVinDetected = onDetected;
    _isStreaming = true;
    _detectionCounts.clear();
    _lastProcessTime = null;

    try {
      await _cameraController!.startImageStream(_processImageStream);
    } catch (e) {
      debugPrint('Start stream error: $e');
      _isStreaming = false;
    }
  }

  Future<void> stopContinuousScanning() async {
    if (!_isStreaming) return;

    _isStreaming = false;
    onVinDetected = null;
    _detectionCounts.clear();

    try {
      await _cameraController?.stopImageStream();
    } catch (e) {
      debugPrint('Stop stream error: $e');
    }
  }

  void _processImageStream(CameraImage image) async {
    if (_isProcessing || !_isStreaming || _textRecognizer == null) return;

    final now = DateTime.now();
    if (_lastProcessTime != null &&
        now.difference(_lastProcessTime!) < _processInterval) {
      return;
    }
    _lastProcessTime = now;

    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final recognizedText = await _textRecognizer!.processImage(inputImage);

      if (recognizedText.text.isNotEmpty) {
        onDebugText?.call(recognizedText.text);
        final candidates = _findAllCandidates(recognizedText);
        for (final candidate in candidates) {
          _addToBuffer(candidate);
          final stableResult = _getStableDetection();
          if (stableResult != null) {
            onVinDetected?.call(VinScanResult.success(
              stableResult,
              confidence: _detectionCounts[stableResult]! / _maxBufferSize,
            ));
            _detectionCounts.clear();
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Stream process error: $e');
    }

    _isProcessing = false;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = _cameras?.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      if (camera == null) return null;

      final sensorOrientation = camera.sensorOrientation;

      InputImageRotation? rotation;
      if (Platform.isAndroid) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      } else if (Platform.isIOS) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      }

      rotation ??= InputImageRotation.rotation0deg;

      final format = Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888;

      final plane = image.planes.first;

      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Convert image error: $e');
      return null;
    }
  }

  List<String> _findAllCandidates(RecognizedText recognizedText) {
    final candidates = <String>{};
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final lineText = line.text;
        final cleaned = _cleanForSearch(lineText);
        if (cleaned.length == 17 && _isValidCandidate(cleaned)) {
          candidates.add(cleaned);
        }
        if (cleaned.length > 17) {
          final extracted = _extract17CharPatterns(cleaned);
          for (final e in extracted) {
            if (_isValidCandidate(e)) {
              candidates.add(e);
            }
          }
        }
        for (final element in line.elements) {
          final elemCleaned = _cleanForSearch(element.text);
          if (elemCleaned.length == 17 && _isValidCandidate(elemCleaned)) {
            candidates.add(elemCleaned);
          }
        }
      }
    }

    return candidates.toList();
  }

  String _cleanForSearch(String text) {
    return text
        .toUpperCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('_', '')
        .replaceAll(':', '')
        .replaceAll(';', '')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim();
  }

  List<String> _extract17CharPatterns(String text) {
    final results = <String>[];
    if (text.length >= 17) {
      for (int i = 0; i <= text.length - 17; i++) {
        final substring = text.substring(i, i + 17);
        if (_isValidCandidate(substring)) {
          results.add(substring);
        }
      }
    }
    return results;
  }

  bool _isValidCandidate(String text) {
    if (text.length != 17) return false;
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(text)) {
      return false;
    }
    final letterCount = text.replaceAll(RegExp(r'[0-9]'), '').length;
    final digitCount = text.replaceAll(RegExp(r'[A-Z]'), '').length;

    if (letterCount < 2 || digitCount < 2) {
      return false;
    }
    for (int i = 0; i < text.length - 4; i++) {
      if (text[i] == text[i + 1] &&
          text[i] == text[i + 2] &&
          text[i] == text[i + 3] &&
          text[i] == text[i + 4]) {
        return false;
      }
    }

    return true;
  }

  void _addToBuffer(String candidate) {
    _detectionCounts[candidate] = (_detectionCounts[candidate] ?? 0) + 1;
    if (_detectionCounts.length > _maxBufferSize) {
      final sorted = _detectionCounts.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      for (int i = 0; i < sorted.length ~/ 2; i++) {
        _detectionCounts.remove(sorted[i].key);
      }
    }

    debugPrint('Detection buffer: $_detectionCounts');
  }

  String? _getStableDetection() {
    for (final entry in _detectionCounts.entries) {
      if (entry.value >= _requiredDetections) {
        debugPrint(
            'Stable detection found: ${entry.key} (${entry.value} times)');
        return entry.key;
      }
    }
    return null;
  }

  Future<VinScanResult> captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        'Camera not initialized',
      );
    }

    if (_isProcessing) {
      return VinScanResult.failure(
        ScannerError.processingFailed,
        'Already processing',
      );
    }

    if (_isStreaming) {
      await stopContinuousScanning();
    }

    _isProcessing = true;

    try {
      try {
        await _cameraController!.setFocusMode(FocusMode.locked);
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (_) {}

      final XFile imageFile = await _cameraController!.takePicture();
      final result = await _processImageFile(File(imageFile.path));

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (_) {}

      try {
        await File(imageFile.path).delete();
      } catch (_) {}

      return result;
    } catch (e) {
      debugPrint('Capture error: $e');
      return VinScanResult.failure(
        ScannerError.processingFailed,
        'Failed to capture image',
      );
    } finally {
      _isProcessing = false;
    }
  }

  Future<VinScanResult> _processImageFile(File imageFile) async {
    if (_textRecognizer == null) {
      return VinScanResult.failure(
        ScannerError.processingFailed,
        'Text recognizer not initialized',
      );
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer!.processImage(inputImage);

      debugPrint('=== Manual Capture OCR ===');
      debugPrint('Full text: ${recognizedText.text}');

      if (recognizedText.text.isEmpty) {
        return VinScanResult.failure(
          ScannerError.noTextFound,
          'No text detected. Try better lighting.',
        );
      }

      final candidates = _findAllCandidates(recognizedText);

      debugPrint('Candidates found: $candidates');

      if (candidates.isNotEmpty) {
        return VinScanResult.success(candidates.first);
      }

      return VinScanResult.failure(
        ScannerError.noVinFound,
        'No 17-character code found. Make sure the full code is visible.',
      );
    } catch (e) {
      debugPrint('Process image error: $e');
      return VinScanResult.failure(
        ScannerError.processingFailed,
        'Failed to process image',
      );
    }
  }

  Future<bool> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return false;
    }

    try {
      final currentMode = _cameraController!.value.flashMode;
      final newMode =
          currentMode == FlashMode.torch ? FlashMode.off : FlashMode.torch;

      await _cameraController!.setFlashMode(newMode);
      return newMode == FlashMode.torch;
    } catch (e) {
      debugPrint('Flash toggle error: $e');
      return false;
    }
  }

  Future<void> setZoom(double level) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final minZoom = await _cameraController!.getMinZoomLevel();
      final maxZoom = await _cameraController!.getMaxZoomLevel();
      final zoom = minZoom + (maxZoom - minZoom) * level.clamp(0.0, 1.0);
      await _cameraController!.setZoomLevel(zoom);
    } catch (e) {
      debugPrint('Zoom error: $e');
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await stopContinuousScanning();
    await _cameraController?.dispose();
    _cameraController = null;
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}
