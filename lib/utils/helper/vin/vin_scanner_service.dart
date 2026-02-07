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
import '../../../../core/localization/app_translation.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../config/vin_scanner_config.dart';
import 'camera_manager.dart';

class VinScannerService {
  final VinScannerConfig _config;
  late final CameraManager _cameraManager;
  final VinValidator _vinValidator = VinValidator();
  TextRecognizer? _textRecognizer;
  bool _isProcessing = false;
  bool _isDisposed = false;
  bool _isStreaming = false;
  void Function(VinScanResult)? onVinDetected;
  void Function(String)? onDebugText;
  final Map<String, int> _detectionCounts = {};
  final Map<String, int> _checksumValidCounts = {};
  final Map<String, Set<String>> _vinSourceReadings = {};

  static const double _roiTopRatio = 0.30;
  static const double _roiBottomRatio = 0.70;
  static const double _roiLeftRatio = 0.05;
  static const double _roiRightRatio = 0.95;

  DateTime? _lastProcessTime;
  DateTime _lastFocusTriggerTime = DateTime.now();
  String? _foundVin;
  double? _foundConfidence;
  Timer? _captureTimer;

  double get minZoomLevel => _cameraManager.minZoomLevel;
  double get maxZoomLevel => _cameraManager.maxZoomLevel;
  double get currentZoomLevel => _cameraManager.currentZoomLevel;
  CameraController? get cameraController => _cameraManager.controller;
  bool get isProcessing => _isProcessing;
  bool get isInitialized => _cameraManager.isInitialized;

  VinScannerService({required VinScannerConfig config}) : _config = config {
    _cameraManager = CameraManager(config: config);
  }

  Rect getRoiBounds(Size screenSize) {
    return Rect.fromLTRB(
      screenSize.width * _roiLeftRatio,
      screenSize.height * _roiTopRatio,
      screenSize.width * _roiRightRatio,
      screenSize.height * _roiBottomRatio,
    );
  }

  TextRecognizer _createRecognizer() {
    debugPrint('Creating TextRecognizer...');
    return TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<TextRecognizer> _acquireRecognizer() async {
    if (_textRecognizer != null) return _textRecognizer!;

    final recognizer = _createRecognizer();

    if (!_config.disposeRecognizerAfterEachScan) {
      _textRecognizer = recognizer;
    }

    return recognizer;
  }

  Future<void> _releaseRecognizer(TextRecognizer recognizer) async {
    if (_config.disposeRecognizerAfterEachScan) {
      debugPrint('Closing TextRecognizer to free native memory...');
      await recognizer.close();
      _textRecognizer = null;

      // Give OS time to reclaim native memory before next allocation
      if (_config.postOcrDelay > Duration.zero) {
        debugPrint(
          'Post-OCR delay: ${_config.postOcrDelay.inMilliseconds}ms '
              '(waiting for GC)',
        );
        await Future.delayed(_config.postOcrDelay);
      }
    }
  }

  Future<VinScanResult?> initialize() async {
    if (_isDisposed) return null;

    try {
      if (!_config.disposeRecognizerAfterEachScan) {
        _textRecognizer = _createRecognizer();
      } else {
        debugPrint(
          'TextRecognizer deferred — will lazy-init during first capture',
        );
      }

      final cameraResult = await _cameraManager.initialize();

      if (!cameraResult.isSuccess) {
        if (cameraResult.isCameraUnavailable) {
          return VinScanResult.failure(
            ScannerError.noCameraAvailable,
            cameraResult.errorMessage ??
                AppTranslation.translate(AppStrings.noCameraAvailable),
          );
        }

        if (cameraResult.isPermissionDenied) {
          return VinScanResult.failure(
            ScannerError.permissionDenied,
            cameraResult.errorMessage ??
                AppTranslation.translate(AppStrings.cameraPermissionDenied),
          );
        }

        return VinScanResult.failure(
          ScannerError.cameraInitFailed,
          cameraResult.errorMessage ??
              AppTranslation.translate(AppStrings.failedToInitializeCamera),
        );
      }

      return null;
    } catch (e) {
      debugPrint('Init error: $e');

      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        AppTranslation.translate(AppStrings.failedToInitializeCamera),
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

    if (_config.scanMode == ScanMode.periodicCapture) {
      _startPeriodicCapture();
    } else {
      _startStreamScanning();
    }
  }

  Future<void> stopContinuousScanning() async {
    if (!_isStreaming) return;

    _isStreaming = false;
    onVinDetected = null;
    _resetScanState();

    _captureTimer?.cancel();
    _captureTimer = null;

    await _cameraManager.stopImageStream();
  }

  Future<void> _startStreamScanning() async {
    try {
      await _cameraManager.startImageStream(_processImageStream);
    } catch (e) {
      debugPrint('Start stream error: $e');
      _isStreaming = false;
    }
  }

  void _processImageStream(CameraImage image) {
    if (_isDisposed ||
        _isProcessing ||
        !_isStreaming ||
        _textRecognizer == null) {
      return;
    }

    if (_foundVin != null) {
      _notifyFoundVin();
      return;
    }

    final now = DateTime.now();

    if (_lastProcessTime != null &&
        now.difference(_lastProcessTime!) < _config.processInterval) {
      return;
    }

    _lastProcessTime = now;
    _isProcessing = true;
    _processFrame(image);
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      if (_isDisposed) return;

      final inputImage = _cameraManager.convertCameraImage(image);
      if (inputImage == null) return;

      if (_isDisposed || _textRecognizer == null) return;

      final recognizedText = await _textRecognizer!.processImage(inputImage);

      if (_isDisposed || !_isStreaming) return;

      if (_config.enablePeriodicRefocus) {
        _handlePeriodicRefocus();
      }

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

  void _startPeriodicCapture() {
    debugPrint(
      'Starting periodic capture mode '
          '(initialDelay: ${_config.initialCaptureDelay.inMilliseconds}ms, '
          'interval: ${_config.captureInterval.inMilliseconds}ms, '
          'disposeRecognizer: ${_config.disposeRecognizerAfterEachScan})',
    );

    if (_config.initialCaptureDelay > Duration.zero) {
      debugPrint(
        'Waiting ${_config.initialCaptureDelay.inSeconds}s for camera '
            'to stabilize before first capture...',
      );

      Future.delayed(_config.initialCaptureDelay, () {
        if (!_isStreaming || _isDisposed) return;

        debugPrint('Initial delay complete — starting capture loop');
        _captureAndProcess();
        _startCaptureTimer();
      });
    } else {
      _captureAndProcess();
      _startCaptureTimer();
    }
  }

  void _startCaptureTimer() {
    _captureTimer = Timer.periodic(_config.captureInterval, (_) {
      if (_isStreaming && !_isProcessing && _foundVin == null) {
        _captureAndProcess();
      }
    });
  }

  Future<void> _captureAndProcess() async {
    if (_isDisposed || _isProcessing || !_isStreaming) return;

    _isProcessing = true;

    TextRecognizer? recognizer;

    try {
      if (_isDisposed || !_cameraManager.isInitialized) return;

      debugPrint('📸 Taking picture...');
      final imagePath = await _cameraManager.takePicture();

      if (imagePath == null || _isDisposed || !_isStreaming) return;

      final imageFile = File(imagePath);

      try {
        recognizer = await _acquireRecognizer();

        if (_isDisposed || !_isStreaming) return;

        debugPrint('🔍 Running OCR...');
        final inputImage = InputImage.fromFile(imageFile);
        final recognizedText = await recognizer.processImage(inputImage);

        if (_isDisposed || !_isStreaming) return;

        debugPrint(
          'OCR complete: ${recognizedText.text.length} chars detected',
        );

        await _releaseRecognizer(recognizer);
        recognizer = null;

        if (_isDisposed || !_isStreaming) return;

        onDebugText?.call(recognizedText.text);

        final candidates = _findAllCandidates(recognizedText);

        debugPrint('Candidates: ${candidates.length}');

        for (final candidate in candidates) {
          _evaluateCandidate(candidate);

          if (_foundVin != null) {
            _notifyFoundVin();
            return;
          }
        }
      } finally {
        if (recognizer != null && _config.disposeRecognizerAfterEachScan) {
          try {
            await recognizer.close();
          } catch (_) {}
        }
        try {
          await imageFile.delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Periodic capture error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _resetScanState() {
    _detectionCounts.clear();
    _checksumValidCounts.clear();
    _vinSourceReadings.clear();
    _lastProcessTime = null;
    _lastFocusTriggerTime = DateTime.now();
    _foundVin = null;
    _foundConfidence = null;
  }

  void _notifyFoundVin() {
    final vin = _foundVin!;
    final confidence = _foundConfidence ?? 1.0;

    _foundVin = null;
    _foundConfidence = null;

    _captureTimer?.cancel();
    _captureTimer = null;

    onVinDetected?.call(VinScanResult.success(vin, confidence: confidence));
    _isStreaming = false;
  }

  void _handlePeriodicRefocus() {
    final now = DateTime.now();

    if (_foundVin == null &&
        now.difference(_lastFocusTriggerTime) > _config.focusDebounceInterval) {
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
      return;
    }

    final validVariants =
    _vinValidator.findAllValidVariants(correctedCandidate);

    if (validVariants.isEmpty) {
      _addToDetectionBuffer(correctedCandidate);
      return;
    }

    for (final variant in validVariants) {
      _vinSourceReadings.putIfAbsent(variant, () => {});
      _vinSourceReadings[variant]!.add(correctedCandidate);
    }

    debugPrint(
        '📊 Valid variants for "$correctedCandidate": ${validVariants.join(", ")}');

    final bestVariant = _selectBestValidVin(validVariants, correctedCandidate);

    _addToChecksumValidBuffer(bestVariant);
  }

  String _selectBestValidVin(List<String> variants, String rawReading) {
    if (variants.length == 1) return variants.first;

    int bestScore = -1;
    String? bestVariant;

    for (final variant in variants) {
      int score = 0;

      final sourceCount = _vinSourceReadings[variant]?.length ?? 0;
      score += sourceCount * 15;

      final bufferCount = _checksumValidCounts[variant] ?? 0;
      score += bufferCount * 10;

      int differences = 0;
      for (int i = 0; i < 17; i++) {
        if (variant[i] != rawReading[i]) differences++;
      }
      score += (17 - differences);

      if (RegExp(r'[1-9]').hasMatch(variant[0])) {
        score += 25;
      }

      final serialSection = variant.substring(11);
      final digitsInSerial =
          serialSection.replaceAll(RegExp(r'[^0-9]'), '').length;
      score += digitsInSerial * 3;

      debugPrint(
          '   📈 $variant: sources=$sourceCount, buffer=$bufferCount, diff=$differences, score=$score');

      if (score > bestScore) {
        bestScore = score;
        bestVariant = variant;
      }
    }

    return bestVariant ?? variants.first;
  }

  void _addToChecksumValidBuffer(String candidate) {
    _checksumValidCounts[candidate] =
        (_checksumValidCounts[candidate] ?? 0) + 1;

    debugPrint(
        'Buffer (checksum valid): $candidate = ${_checksumValidCounts[candidate]}');

    if (_checksumValidCounts[candidate]! >=
        _config.requiredDetectionsForChecksum) {
      if (_isConfidentWinner(candidate)) {
        debugPrint('✓ Checksum valid + stable + confident: $candidate');
        _foundVin = candidate;
        _foundConfidence = 1.0;
      } else {
        debugPrint('⚠ Threshold reached but not confident yet, waiting...');
      }
    }
  }

  bool _isConfidentWinner(String candidate) {
    final candidateCount = _checksumValidCounts[candidate] ?? 0;
    final candidateSources = _vinSourceReadings[candidate]?.length ?? 0;

    int maxCompetitorCount = 0;
    String? topCompetitor;

    for (final entry in _checksumValidCounts.entries) {
      if (entry.key != candidate) {
        if (!_vinValidator.areAmbiguousEquivalent(entry.key, candidate)) {
          if (entry.value > maxCompetitorCount) {
            maxCompetitorCount = entry.value;
            topCompetitor = entry.key;
          }
        }
      }
    }

    debugPrint(
        '🔍 Confidence: $candidate($candidateCount, src:$candidateSources) vs $topCompetitor($maxCompetitorCount)');

    if (maxCompetitorCount == 0) return true;
    if (candidateSources >= 2) return true;
    if (candidateCount >= maxCompetitorCount * 2) return true;

    return false;
  }

  void _addToDetectionBuffer(String candidate) {
    _detectionCounts[candidate] = (_detectionCounts[candidate] ?? 0) + 1;

    debugPrint(
        'Buffer (no checksum): $candidate = ${_detectionCounts[candidate]}');

    if (_detectionCounts.length > _config.maxBufferSize) {
      _pruneDetectionBuffer();
    }

    final stableResult = _getStableDetection();

    if (stableResult != null) {
      debugPrint('✓ Stable detection (no checksum): $stableResult');
      _foundVin = stableResult;

      final extraDetections = _detectionCounts[stableResult]! -
          _config.requiredDetectionsForNonChecksum;
      _foundConfidence = (0.75 + (extraDetections * 0.05)).clamp(0.75, 0.95);
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
      if (entry.value >= _config.requiredDetectionsForNonChecksum) {
        return entry.key;
      }
    }
    return null;
  }

  Future<VinScanResult> captureAndScan() async {
    if (_isDisposed) {
      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        AppTranslation.translate(AppStrings.scannerDisposed),
      );
    }

    if (!_cameraManager.isInitialized) {
      return VinScanResult.failure(
        ScannerError.cameraInitFailed,
        AppTranslation.translate(AppStrings.cameraNotInitialized),
      );
    }

    if (_isProcessing) {
      return VinScanResult.failure(
        ScannerError.processingFailed,
        AppTranslation.translate(AppStrings.alreadyProcessing),
      );
    }

    if (_isStreaming) {
      await stopContinuousScanning();
    }

    _isProcessing = true;

    TextRecognizer? recognizer;

    try {
      await _cameraManager.setFocusMode(FocusMode.locked);
      await Future.delayed(const Duration(milliseconds: 500));

      if (_isDisposed) {
        return VinScanResult.failure(
          ScannerError.cameraInitFailed,
          AppTranslation.translate(AppStrings.scannerDisposed),
        );
      }

      final imagePath = await _cameraManager.takePicture();

      if (imagePath == null) {
        return VinScanResult.failure(
          ScannerError.processingFailed,
          AppTranslation.translate(AppStrings.failedToCaptureImage),
        );
      }

      recognizer = await _acquireRecognizer();

      final result = await _processImageFile(File(imagePath), recognizer);

      await _releaseRecognizer(recognizer);
      recognizer = null;

      await _cameraManager.setFocusMode(FocusMode.auto);

      try {
        await File(imagePath).delete();
      } catch (_) {}

      return result;
    } catch (e) {
      debugPrint('Capture error: $e');

      return VinScanResult.failure(
        ScannerError.processingFailed,
        AppTranslation.translate(AppStrings.failedToCaptureImage),
      );
    } finally {
      if (recognizer != null && _config.disposeRecognizerAfterEachScan) {
        try {
          await recognizer.close();
        } catch (_) {}
      }
      _isProcessing = false;
    }
  }

  Future<VinScanResult> _processImageFile(
      File imageFile,
      TextRecognizer recognizer,
      ) async {
    if (_isDisposed) {
      return VinScanResult.failure(
        ScannerError.processingFailed,
        AppTranslation.translate(AppStrings.scannerNotReady),
      );
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);

      final recognizedText = await recognizer.processImage(inputImage);

      debugPrint('=== Manual Capture OCR ===');
      debugPrint('Full text: ${recognizedText.text}');

      if (recognizedText.text.isEmpty) {
        return VinScanResult.failure(
          ScannerError.noTextFound,
          AppTranslation.translate(AppStrings.noTextDetected),
        );
      }

      final candidates = _findAllCandidates(recognizedText);

      debugPrint('Candidates found: $candidates');

      if (candidates.isNotEmpty) {
        final allValidVariants = <String>[];

        for (final candidate in candidates) {
          allValidVariants
              .addAll(_vinValidator.findAllValidVariants(candidate));
        }

        if (allValidVariants.isNotEmpty) {
          final bestVariant = _vinValidator.findValidVariant(candidates.first);

          if (bestVariant != null) {
            debugPrint('✓ Manual capture: Valid VIN found: $bestVariant');
            return VinScanResult.success(bestVariant, confidence: 1.0);
          }
        }

        debugPrint(
            '⚠ Manual capture: No checksum match, returning first candidate');
        return VinScanResult.success(candidates.first, confidence: 0.8);
      }

      return VinScanResult.failure(
        ScannerError.noVinFound,
        AppTranslation.translate(AppStrings.noVinFound),
      );
    } catch (e) {
      debugPrint('Process image error: $e');

      return VinScanResult.failure(
        ScannerError.processingFailed,
        AppTranslation.translate(AppStrings.failedToProcessImage),
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

    _captureTimer?.cancel();
    _captureTimer = null;

    await stopContinuousScanning();
    await _cameraManager.dispose();
    await _textRecognizer?.close();
    _textRecognizer = null;
    _resetScanState();
  }
}