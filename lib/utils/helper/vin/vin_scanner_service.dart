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
  final Map<String, int> _checksumValidCounts = {};
  final Map<String, Set<String>> _vinSourceReadings = {};
  static const int _requiredDetectionsForNonChecksum = 5;
  static const int _requiredDetectionsForChecksum = 5;
  static const int _maxBufferSize = 20;
  DateTime? _lastProcessTime;
  DateTime _lastFocusTriggerTime = DateTime.now();
  static const _focusDebounceInterval = Duration(milliseconds: 3500);
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

    _checksumValidCounts.clear();

    _vinSourceReadings.clear();

    _lastProcessTime = null;

    _lastFocusTriggerTime = DateTime.now();

    _foundVin = null;

    _foundConfidence = null;
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

      // 1. Bu varyantı kaç farklı raw okuma destekliyor?

      final sourceCount = _vinSourceReadings[variant]?.length ?? 0;

      score += sourceCount * 15;

      // 2. Buffer'daki mevcut sayısı

      final bufferCount = _checksumValidCounts[variant] ?? 0;

      score += bufferCount * 10;

      // 3. Raw okumaya yakınlık (AZALTILDI)

      int differences = 0;

      for (int i = 0; i < 17; i++) {
        if (variant[i] != rawReading[i]) differences++;
      }

      score += (17 - differences);

      // 4. İlk karakter rakam bonusu (ARTIRILDI)

      if (RegExp(r'[1-9]').hasMatch(variant[0])) {
        score += 25;
      }

      // 5. Son 6 hane rakam bonusu (ARTIRILDI)

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

    if (_checksumValidCounts[candidate]! >= _requiredDetectionsForChecksum) {
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

    if (_detectionCounts.length > _maxBufferSize) {
      _pruneDetectionBuffer();
    }

    final stableResult = _getStableDetection();

    if (stableResult != null) {
      debugPrint('✓ Stable detection (no checksum): $stableResult');

      _foundVin = stableResult;

      final extraDetections =
          _detectionCounts[stableResult]! - _requiredDetectionsForNonChecksum;

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
        AppTranslation.translate(AppStrings.failedToCaptureImage),
      );
    } finally {
      _isProcessing = false;
    }
  }

  Future<VinScanResult> _processImageFile(File imageFile) async {
    if (_isDisposed || _textRecognizer == null) {
      return VinScanResult.failure(
        ScannerError.processingFailed,
        AppTranslation.translate(AppStrings.scannerNotReady),
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
          AppTranslation.translate(AppStrings.noTextDetected),
        );
      }

      final candidates = _findAllCandidates(recognizedText);

      debugPrint('Candidates found: $candidates');

      if (candidates.isNotEmpty) {
        // Tüm adaylardan tüm valid varyantları topla

        final allValidVariants = <String>[];

        for (final candidate in candidates) {
          allValidVariants
              .addAll(_vinValidator.findAllValidVariants(candidate));
        }

        if (allValidVariants.isNotEmpty) {
          // En iyi varyantı seç

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

    await stopContinuousScanning();

    await _cameraManager.dispose();

    await _textRecognizer?.close();

    _textRecognizer = null;

    _resetScanState();
  }
}
