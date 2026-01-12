import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:carcat/utils/helper/vin/vin_ocr_extensions.dart';
import 'package:carcat/utils/helper/vin/vin_scan_result.dart';
import 'package:carcat/utils/helper/vin/vin_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/constants/enums/enums.dart';
import 'camera_manager.dart';

class VinScannerService {
  final CameraManager _cameraManager = CameraManager();
  final VinValidator _vinValidator = VinValidator();
  TextRecognizer? _textRecognizer;
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
  String? _foundVin;
  double? _foundConfidence;
  double get minZoomLevel => _cameraManager.minZoomLevel;
  double get maxZoomLevel => _cameraManager.maxZoomLevel;
  double get currentZoomLevel => _cameraManager.currentZoomLevel;
  CameraController? get cameraController => _cameraManager.controller;
  bool get isProcessing => _isProcessing;
  bool get isInitialized => _cameraManager.isInitialized;

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

      final cameraResult = await _cameraManager.initialize();

      if (!cameraResult.isSuccess) {
        if (cameraResult.isCameraUnavailable) {
          return VinScanResult.failure(
            ScannerError.noCameraAvailable,
            cameraResult.errorMessage ?? 'No camera available',
          );
        }
        if (cameraResult.isPermissionDenied) {
          return VinScanResult.failure(
            ScannerError.permissionDenied,
            cameraResult.errorMessage ?? 'Camera permission denied',
          );
        }
        return VinScanResult.failure(
          ScannerError.cameraInitFailed,
          cameraResult.errorMessage ?? 'Failed to initialize camera',
        );
      }

      return null; // Success
    } catch (e) {
      debugPrint('Init error: $e');
      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        'Failed to initialize camera',
      );
    }
  }

  Future<void> startContinuousScanning(
      void Function(VinScanResult) onDetected,
      ) async {
    if (!_cameraManager.isInitialized || _isStreaming) return;

    onVinDetected = onDetected;
    _isStreaming = true;
    _resetScanState();

    try {
      await _cameraManager.startImageStream(_processImageStream);
    } catch (e) {
      debugPrint('Start stream error: $e');
      _isStreaming = false;
    }
  }

  Future<void> stopContinuousScanning() async {
    if (!_isStreaming) return;

    _isStreaming = false;
    onVinDetected = null;
    _resetScanState();

    await _cameraManager.stopImageStream();
  }

  void _resetScanState() {
    _detectionCounts.clear();
    _lastProcessTime = null;
    _lastFocusTriggerTime = DateTime.now();
    _foundVin = null;
    _foundConfidence = null;
  }

  void _processImageStream(CameraImage image) {
    if (_isDisposed || _isProcessing || !_isStreaming || _textRecognizer == null) {
      return;
    }

    if (_foundVin != null) {
      _notifyFoundVin();
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

  void _notifyFoundVin() {
    final vin = _foundVin!;
    final confidence = _foundConfidence ?? 1.0;
    _foundVin = null;
    _foundConfidence = null;

    onVinDetected?.call(VinScanResult.success(vin, confidence: confidence));
    _isStreaming = false;
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      if (_isDisposed) return;

      final inputImage = _cameraManager.convertCameraImage(image);
      if (inputImage == null) return;

      if (_isDisposed || _textRecognizer == null) return;

      final recognizedText = await _textRecognizer!.processImage(inputImage);

      if (_isDisposed || !_isStreaming) return;

      _handlePeriodicRefocus();

      onDebugText?.call(recognizedText.text);

      final candidates = _findCandidatesInRoi(
        recognizedText,
        imageWidth: image.width.toDouble(),
        imageHeight: image.height.toDouble(),
      );

      for (final candidate in candidates) {
        _evaluateCandidate(candidate);
        if (_foundVin != null) break;
      }
    } catch (e) {
      debugPrint('Stream process error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _handlePeriodicRefocus() {
    final now = DateTime.now();
    if (_foundVin == null &&
        now.difference(_lastFocusTriggerTime) > _focusDebounceInterval) {
      debugPrint('Refocusing triggered explicitly to clear blur...');
      _cameraManager.triggerCenterFocus();
      _lastFocusTriggerTime = now;
    }
  }

  List<String> _findCandidatesInRoi(
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

      if (boundingBox.bottom < roiTop || boundingBox.top > roiBottom) continue;
      if (boundingBox.right < roiLeft || boundingBox.left > roiRight) continue;

      _extractCandidatesFromBlock(block, candidates);
    }

    return candidates.toList();
  }

  void _extractCandidatesFromBlock(TextBlock block, Set<String> candidates) {
    for (final line in block.lines) {
      final rawLineText = line.text.toUpperCase();

      final boundaryExtracted = _vinValidator
          .extract17CharPatternsWithBoundary(rawLineText.applyOcrCorrections());
      for (final candidate in boundaryExtracted) {
        if (_vinValidator.isValidCandidate(candidate)) {
          candidates.add(candidate);
        }
      }

      final cleaned = rawLineText.cleanForVinSearch();
      if (cleaned.length == 17 && _vinValidator.isValidCandidate(cleaned)) {
        candidates.add(cleaned);
      }

      for (final element in line.elements) {
        final elemRaw = element.text.toUpperCase();

        final elemBoundary = _vinValidator
            .extract17CharPatternsWithBoundary(elemRaw.applyOcrCorrections());
        for (final candidate in elemBoundary) {
          if (_vinValidator.isValidCandidate(candidate)) {
            candidates.add(candidate);
          }
        }

        final elemCleaned = elemRaw.cleanForVinSearch();
        if (elemCleaned.length == 17 &&
            _vinValidator.isValidCandidate(elemCleaned)) {
          candidates.add(elemCleaned);
        }
      }
    }
  }

  void _evaluateCandidate(String candidate) {
    final correctedCandidate = candidate.applyOcrCorrections();

    if (!_vinValidator.isValidCandidate(correctedCandidate)) {
      debugPrint('✗ Candidate invalid after OCR correction: $correctedCandidate');
      return;
    }

    if (_vinValidator.validateChecksum(correctedCandidate)) {
      debugPrint('✓ Checksum valid! Instant accept: $correctedCandidate');
      _foundVin = correctedCandidate;
      _foundConfidence = 1.0;
      return;
    }

    final validVariant = _vinValidator.findValidVariant(correctedCandidate);
    if (validVariant != null) {
      debugPrint('✓ Valid variant found! Instant accept: $validVariant');
      _foundVin = validVariant;
      _foundConfidence = 1.0;
      return;
    }

    _addToDetectionBuffer(correctedCandidate);
  }

  void _addToDetectionBuffer(String candidate) {
    _detectionCounts[candidate] = (_detectionCounts[candidate] ?? 0) + 1;
    debugPrint('Buffer (no checksum): $candidate = ${_detectionCounts[candidate]}');

    if (_detectionCounts.length > _maxBufferSize) {
      _pruneDetectionBuffer();
    }

    final stableResult = _getStableDetection();
    if (stableResult != null) {
      debugPrint('✓ Stable detection (no checksum): $stableResult');
      _foundVin = stableResult;
      _foundConfidence =
          _detectionCounts[stableResult]! / _requiredDetectionsForNonChecksum;
    }
  }

  void _pruneDetectionBuffer() {
    final sorted = _detectionCounts.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    for (int i = 0; i < sorted.length ~/ 2; i++) {
      _detectionCounts.remove(sorted[i].key);
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

    if (!_cameraManager.isInitialized) {
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
      await _cameraManager.setFocusMode(FocusMode.locked);
      await Future.delayed(const Duration(milliseconds: 500));

      if (_isDisposed) {
        return VinScanResult.failure(
          ScannerError.cameraInitFailed,
          'Scanner has been disposed',
        );
      }

      final imagePath = await _cameraManager.takePicture();
      if (imagePath == null) {
        return VinScanResult.failure(
          ScannerError.processingFailed,
          'Failed to capture image',
        );
      }

      final result = await _processImageFile(File(imagePath));

      await _cameraManager.setFocusMode(FocusMode.auto);

      try {
        await File(imagePath).delete();
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
    if (_isDisposed || _textRecognizer == null) {
      return VinScanResult.failure(
        ScannerError.processingFailed,
        'Scanner not ready',
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
        for (final candidate in candidates) {
          final validVariant = _vinValidator.findValidVariant(candidate);
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

  List<String> _findAllCandidates(RecognizedText recognizedText) {
    final candidates = <String>{};

    for (final block in recognizedText.blocks) {
      _extractCandidatesFromBlock(block, candidates);
    }

    return candidates.toList();
  }

  Future<bool> toggleFlash() => _cameraManager.toggleFlash();

  Future<void> setZoom(double normalizedLevel) =>
      _cameraManager.setZoomNormalized(normalizedLevel);

  Future<void> setZoomLevel(double absoluteLevel) =>
      _cameraManager.setZoomLevel(absoluteLevel);

  Future<void> setFocusPoint(Offset point, Size previewSize) =>
      _cameraManager.setFocusPoint(point, previewSize);

  Future<void> dispose() async {
    _isDisposed = true;
    await stopContinuousScanning();
    await _cameraManager.dispose();
    await _textRecognizer?.close();
    _textRecognizer = null;
    _resetScanState();
  }
}