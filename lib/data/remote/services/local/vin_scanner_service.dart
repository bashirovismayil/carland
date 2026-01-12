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
  static const int _requiredDetectionsForNonChecksum = 2;
  static const int _maxBufferSize = 20;
  DateTime? _lastProcessTime;
  DateTime _lastFocusTriggerTime = DateTime.now();
  static const _focusDebounceInterval = Duration(milliseconds: 2000);
  static const _processInterval = Duration(milliseconds: 100);
  static const double _roiTopRatio = 0.30;
  static const double _roiBottomRatio = 0.70;
  static const double _roiLeftRatio = 0.05;
  static const double _roiRightRatio = 0.95;

  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;

  static const double _targetInitialZoom = 2.0;

  String? _foundVin;
  double? _foundConfidence;

  static final RegExp _vinBoundaryRegex = RegExp(
    r'(?:^|[^A-HJ-NPR-Z0-9])([A-HJ-NPR-Z0-9]{17})(?:$|[^A-HJ-NPR-Z0-9])',
    caseSensitive: false,
  );
  double get minZoomLevel => _minZoomLevel;
  double get maxZoomLevel => _maxZoomLevel;
  double get currentZoomLevel => _currentZoomLevel;

  CameraController? get cameraController => _cameraController;
  bool get isProcessing => _isProcessing;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  Rect getRoiBounds(Size screenSize) {
    return Rect.fromLTRB(
      screenSize.width * _roiLeftRatio,
      screenSize.height * _roiTopRatio,
      screenSize.width * _roiRightRatio,
      screenSize.height * _roiBottomRatio,
    );
  }

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

      await _initializeZoomLevels();
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

  Future<void> _initializeZoomLevels() async {
    if (_cameraController == null) return;

    try {
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

      debugPrint('Zoom levels - Min: $_minZoomLevel, Max: $_maxZoomLevel');

      double targetZoom = _targetInitialZoom;

      if (targetZoom < _minZoomLevel) {
        targetZoom = _minZoomLevel;
      } else if (targetZoom > _maxZoomLevel) {
        targetZoom = _maxZoomLevel;
      }

      await _cameraController!.setZoomLevel(targetZoom);
      _currentZoomLevel = targetZoom;

      debugPrint(
          'Initial zoom set to: $_currentZoomLevel (target was $_targetInitialZoom)');
    } catch (e) {
      debugPrint('Zoom initialization error: $e');
      _minZoomLevel = 1.0;
      _maxZoomLevel = 1.0;
      _currentZoomLevel = 1.0;
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

    await _triggerCenterFocus();
  }

  Future<void> _triggerCenterFocus() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_cameraController!.value.focusMode != FocusMode.auto) {
        await _cameraController!.setFocusMode(FocusMode.auto);
      }

      const centerPoint = Offset(0.5, 0.5);
      await _cameraController!.setFocusPoint(centerPoint);
      await _cameraController!.setExposurePoint(centerPoint);

      debugPrint('Center focus triggered');
    } catch (e) {
      debugPrint('Center focus trigger error: $e');
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
    _lastFocusTriggerTime = DateTime.now();
    _foundVin = null;
    _foundConfidence = null;

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
    _foundVin = null;
    _foundConfidence = null;

    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Stop stream error: $e');
    }
  }

  void _processImageStream(CameraImage image) {
    if (_isDisposed) return;
    if (_isProcessing || !_isStreaming || _textRecognizer == null) return;

    if (_foundVin != null) {
      final vin = _foundVin!;
      final confidence = _foundConfidence ?? 1.0;
      _foundVin = null;
      _foundConfidence = null;

      onVinDetected?.call(VinScanResult.success(vin, confidence: confidence));

      _isStreaming = false;
      return;
    }

    final now = DateTime.now();
    if (_lastProcessTime != null &&
        now.difference(_lastProcessTime!) < _processInterval) {
      return;
    }
    _lastProcessTime = now;

    _isProcessing = true;
    _processFrame(image);
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      if (_isDisposed) return;

      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      if (_isDisposed || _textRecognizer == null) return;

      final recognizedText = await _textRecognizer!.processImage(inputImage);

      if (_isDisposed || !_isStreaming) return;

      final now = DateTime.now();

      if (_foundVin == null) {
        if (now.difference(_lastFocusTriggerTime) > _focusDebounceInterval) {
          debugPrint('Refocusing triggered explicitly to clear blur...');
          _triggerCenterFocus();
          _lastFocusTriggerTime = now;
        }
      }

      onDebugText?.call(recognizedText.text);

      final candidates = _findAllCandidates(
        recognizedText,
        imageWidth: image.width.toDouble(),
        imageHeight: image.height.toDouble(),
      );

      for (final candidate in candidates) {
        _addToBuffer(candidate);

        if (_foundVin != null) break;
      }
    } catch (e) {
      debugPrint('Stream process error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = _cameras?.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      if (camera == null) return null;

      final rotation =
      InputImageRotationValue.fromRawValue(camera.sensorOrientation);
      if (rotation == null) {
        debugPrint('Warning: Could not determine image rotation');
        return null;
      }

      final format = InputImageFormatValue.fromRawValue(image.format.raw);

      if (image.planes.isEmpty) {
        debugPrint('Warning: No image planes available');
        return null;
      }

      final WriteBuffer allBytesBuffer = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytesBuffer.putUint8List(plane.bytes);
      }
      final Uint8List allBytes = allBytesBuffer.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: allBytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format ?? InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Convert image error: $e');
      return null;
    }
  }

  List<String> _findAllCandidates(
      RecognizedText recognizedText, {
        required double imageWidth,
        required double imageHeight,
      }) {
    final candidates = <String>{};

    final roiTop = imageHeight * _roiTopRatio;
    final roiBottom = imageHeight * _roiBottomRatio;
    final roiLeft = imageWidth * _roiLeftRatio;
    final roiRight = imageWidth * _roiRightRatio;

    for (final block in recognizedText.blocks) {
      final boundingBox = block.boundingBox;

      if (boundingBox.bottom < roiTop || boundingBox.top > roiBottom) {
        continue;
      }
      if (boundingBox.right < roiLeft || boundingBox.left > roiRight) {
        continue;
      }

      for (final line in block.lines) {
        final rawLineText = line.text.toUpperCase();

        final boundaryExtracted = _extract17CharPatternsWithBoundary(rawLineText);
        for (final candidate in boundaryExtracted) {
          if (_isValidCandidate(candidate)) {
            candidates.add(candidate);
          }
        }

        final cleaned = _cleanForSearch(rawLineText);
        if (cleaned.length == 17 && _isValidCandidate(cleaned)) {
          candidates.add(cleaned);
        }

        for (final element in line.elements) {
          final elemRaw = element.text.toUpperCase();

          final elemBoundaryExtracted =
          _extract17CharPatternsWithBoundary(elemRaw);
          for (final candidate in elemBoundaryExtracted) {
            if (_isValidCandidate(candidate)) {
              candidates.add(candidate);
            }
          }

          final elemCleaned = _cleanForSearch(elemRaw);
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
        .replaceAll('O', '0')
        .replaceAll('Q', '0')
        .replaceAll('I', '1')
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

  List<String> _extract17CharPatternsWithBoundary(String text) {
    final results = <String>[];
    final correctedText = _applyOcrCorrections(text);
    final matches = _vinBoundaryRegex.allMatches(correctedText);
    for (final match in matches) {
      final candidate = match.group(1);
      if (candidate != null) {
        results.add(candidate.toUpperCase());
      }
    }

    return results;
  }
  String _applyOcrCorrections(String text) {
    return text
        .toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('Q', '0')
        .replaceAll('I', '1');
  }

  static const Map<String, String> _ambiguousCharPairs = {
    'S': '5',
    '5': 'S',
    'B': '8',
    '8': 'B',
    'G': '6',
    '6': 'G',
    'Z': '2',
    '2': 'Z',
  };

  String? _findValidVariant(String candidate) {
    if (_validateVinChecksum(candidate)) {
      return candidate;
    }
    final ambiguousPositions = <int>[];
    for (int i = 0; i < candidate.length; i++) {
      if (_ambiguousCharPairs.containsKey(candidate[i])) {
        ambiguousPositions.add(i);
      }
    }
    if (ambiguousPositions.isEmpty) {
      return null;
    }
    final positionsToCheck = ambiguousPositions.length > 4
        ? ambiguousPositions.sublist(0, 4)
        : ambiguousPositions;
    final combinationCount = 1 << positionsToCheck.length;
    for (int mask = 1; mask < combinationCount; mask++) {
      final chars = candidate.split('');
      for (int i = 0; i < positionsToCheck.length; i++) {
        if ((mask & (1 << i)) != 0) {
          final pos = positionsToCheck[i];
          final originalChar = candidate[pos];
          chars[pos] = _ambiguousCharPairs[originalChar]!;
        }
      }
      final variant = chars.join();
      if (_validateVinChecksum(variant)) {
        debugPrint('✓ Found valid variant: $candidate → $variant');
        return variant;
      }
    }
    return null;
  }
  @Deprecated('Use _extract17CharPatternsWithBoundary instead')
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
    if (text.startsWith('0')) {
      return false;
    }
    if (text.contains('I') || text.contains('O') || text.contains('Q')) {
      return false;
    }
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(text)) {
      return false;
    }
    final letterCount = text.replaceAll(RegExp(r'[0-9]'), '').length;
    final digitCount = 17 - letterCount;
    if (letterCount < 2 || digitCount < 2) {
      return false;
    }
    for (int i = 0; i < 13; i++) {
      if (text[i] == text[i + 1] &&
          text[i] == text[i + 2] &&
          text[i] == text[i + 3] &&
          text[i] == text[i + 4]) {
        return false;
      }
    }
    return true;
  }
  bool _validateVinChecksum(String vin) {
    const transliterationMap = <int, int>{
      65: 1, 66: 2, 67: 3, 68: 4, 69: 5, 70: 6, 71: 7, 72: 8, // A-H
      74: 1, 75: 2, 76: 3, 77: 4, 78: 5, 80: 7, 82: 9, // J-N, P, R
      83: 2, 84: 3, 85: 4, 86: 5, 87: 6, 88: 7, 89: 8, 90: 9, // S-Z
    };
    const weights = <int>[8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 17; i++) {
      final charCode = vin.codeUnitAt(i);
      int value;
      if (charCode >= 48 && charCode <= 57) {
        value = charCode - 48;
      } else {
        final mapped = transliterationMap[charCode];
        if (mapped == null) return false;
        value = mapped;
      }
      sum += value * weights[i];
    }
    final remainder = sum % 11;
    final checkDigit = vin.codeUnitAt(8);
    if (remainder == 10) {
      return checkDigit == 88;
    } else {
      return checkDigit == (remainder + 48);
    }
  }
  void _addToBuffer(String candidate) {
    final correctedCandidate = _applyOcrCorrections(candidate);
    if (!_isValidCandidate(correctedCandidate)) {
      debugPrint('✗ Candidate invalid after OCR correction: $correctedCandidate');
      return;
    }
    if (_validateVinChecksum(correctedCandidate)) {
      debugPrint('✓ Checksum valid! Instant accept: $correctedCandidate');
      _foundVin = correctedCandidate;
      _foundConfidence = 1.0;
      return;
    }
    final validVariant = _findValidVariant(correctedCandidate);
    if (validVariant != null) {
      debugPrint('✓ Valid variant found via checksum! Instant accept: $validVariant');
      _foundVin = validVariant;
      _foundConfidence = 1.0;
      return;
    }
    _detectionCounts[correctedCandidate] =
        (_detectionCounts[correctedCandidate] ?? 0) + 1;
    debugPrint(
        'Buffer (no checksum): $correctedCandidate = ${_detectionCounts[correctedCandidate]}');
    if (_detectionCounts.length > _maxBufferSize) {
      final sorted = _detectionCounts.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      for (int i = 0; i < sorted.length ~/ 2; i++) {
        _detectionCounts.remove(sorted[i].key);
      }
    }
    final stableResult = _getStableDetection();
    if (stableResult != null) {
      debugPrint('✓ Stable detection (no checksum): $stableResult');
      _foundVin = stableResult;
      _foundConfidence =
          _detectionCounts[stableResult]! / _requiredDetectionsForNonChecksum;
    }
  }
  String? _getStableDetection() {
    for (final entry in _detectionCounts.entries) {
      if (entry.value >= _requiredDetectionsForNonChecksum) {
        return entry.key;
      }
    }
    return null;
  }
  Future<VinScanResult> captureAndScan() async {
    if (_isDisposed) {
      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        'Scanner has been disposed',
      );
    }
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
      if (_isDisposed) {
        _isProcessing = false;
        return VinScanResult.failure(
          ScannerError.cameraInitFailed,
          'Scanner has been disposed',
        );
      }
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
    if (_isDisposed) {
      return VinScanResult.failure(
        ScannerError.processingFailed,
        'Scanner has been disposed',
      );
    }
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
      final candidates = _findAllCandidatesWithoutRoi(recognizedText);
      debugPrint('Candidates found: $candidates');
      if (candidates.isNotEmpty) {
        for (final candidate in candidates) {
          final validVariant = _findValidVariant(candidate);
          if (validVariant != null) {
            debugPrint('✓ Manual capture: Valid VIN found: $validVariant');
            return VinScanResult.success(validVariant, confidence: 1.0);
          }
        }
        debugPrint('⚠ Manual capture: No checksum match, returning first candidate');
        return VinScanResult.success(candidates.first, confidence: 0.8);
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
  List<String> _findAllCandidatesWithoutRoi(RecognizedText recognizedText) {
    final candidates = <String>{};
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final rawLineText = line.text.toUpperCase();
        final boundaryExtracted =
        _extract17CharPatternsWithBoundary(rawLineText);
        for (final candidate in boundaryExtracted) {
          if (_isValidCandidate(candidate)) {
            candidates.add(candidate);
          }
        }
        final cleaned = _cleanForSearch(rawLineText);
        if (cleaned.length == 17 && _isValidCandidate(cleaned)) {
          candidates.add(cleaned);
        }
        for (final element in line.elements) {
          final elemRaw = element.text.toUpperCase();
          final elemBoundaryExtracted =
          _extract17CharPatternsWithBoundary(elemRaw);
          for (final candidate in elemBoundaryExtracted) {
            if (_isValidCandidate(candidate)) {
              candidates.add(candidate);
            }
          }
          final elemCleaned = _cleanForSearch(elemRaw);
          if (elemCleaned.length == 17 && _isValidCandidate(elemCleaned)) {
            candidates.add(elemCleaned);
          }
        }
      }
    }
    return candidates.toList();
  }
  Future<bool> toggleFlash() async {
    if (_isDisposed) return false;
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
  Future<void> setZoom(double normalizedLevel) async {
    if (_isDisposed) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final level = normalizedLevel.clamp(0.0, 1.0);
      final zoom = _minZoomLevel + (_maxZoomLevel - _minZoomLevel) * level;
      await _cameraController!.setZoomLevel(zoom);
      _currentZoomLevel = zoom;
    } catch (e) {
      debugPrint('Zoom error: $e');
    }
  }
  Future<void> setZoomLevel(double absoluteLevel) async {
    if (_isDisposed) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final zoom = absoluteLevel.clamp(_minZoomLevel, _maxZoomLevel);
      await _cameraController!.setZoomLevel(zoom);
      _currentZoomLevel = zoom;
    } catch (e) {
      debugPrint('Zoom level error: $e');
    }
  }
  Future<void> dispose() async {
    _isDisposed = true;
    await stopContinuousScanning();
    await _cameraController?.dispose();
    _cameraController = null;
    await _textRecognizer?.close();
    _textRecognizer = null;
    _detectionCounts.clear();
    _foundVin = null;
    _foundConfidence = null;
  }
}