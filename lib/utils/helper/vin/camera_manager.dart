import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../config/vin_scanner_config.dart';

class CameraManager {
  final VinScannerConfig _config;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isDisposed = false;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  double get minZoomLevel => _minZoomLevel;
  double get maxZoomLevel => _maxZoomLevel;
  double get currentZoomLevel => _currentZoomLevel;
  CameraController? get controller => _cameraController;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;
  bool get isDisposed => _isDisposed;
  bool get isStreamingImages =>
      _cameraController?.value.isStreamingImages ?? false;
  FlashMode? get currentFlashMode => _cameraController?.value.flashMode;

  CameraManager({required VinScannerConfig config}) : _config = config;

  Future<CameraInitResult> initialize() async {
    if (_isDisposed) {
      return CameraInitResult.failure('Camera manager has been disposed');
    }

    try {
      return await _initializeWithTimeout();
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} - ${e.description}');

      if (e.code == 'CameraAccessDenied') {
        return CameraInitResult.failure(
          'Camera permission denied',
          isPermissionDenied: true,
        );
      }

      return CameraInitResult.failure(
        'Failed to initialize camera: ${e.description}',
      );
    } catch (e) {
      debugPrint('Camera init error: $e');
      return CameraInitResult.failure('Failed to initialize camera');
    }
  }

  Future<CameraInitResult> _initializeWithTimeout() async {
    final completer = Completer<CameraInitResult>();

    _doInitialize().then((result) {
      if (!completer.isCompleted) completer.complete(result);
    }).catchError((e) {
      if (!completer.isCompleted) {
        completer.complete(
          CameraInitResult.failure('Camera initialization failed: $e'),
        );
      }
    });

    Future.delayed(_config.initializationTimeout, () {
      if (!completer.isCompleted) {
        debugPrint(
          'Camera init timed out after ${_config.initializationTimeout.inSeconds}s',
        );
        completer.complete(
          CameraInitResult.failure(
            'Camera initialization timed out. Please try again.',
          ),
        );
      }
    });

    return completer.future;
  }

  Future<CameraInitResult> _doInitialize() async {
    _cameras = await availableCameras();

    if (_cameras == null || _cameras!.isEmpty) {
      return CameraInitResult.failure(
        'No camera found on this device',
        isCameraUnavailable: true,
      );
    }

    final backCamera = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(
      backCamera,
      _config.resolutionPreset,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();

    if (_isDisposed) {
      return CameraInitResult.failure('Disposed during initialization');
    }

    await _initializeZoomLevels();
    await _setupCameraSettings();

    return CameraInitResult.success();
  }

  Future<void> _initializeZoomLevels() async {
    if (_cameraController == null) return;

    try {
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

      debugPrint('Zoom levels - Min: $_minZoomLevel, Max: $_maxZoomLevel');

      double targetZoom = _config.targetInitialZoom;

      if (targetZoom < _minZoomLevel) {
        targetZoom = _minZoomLevel;
      } else if (targetZoom > _maxZoomLevel) {
        targetZoom = _maxZoomLevel;
      }

      await _cameraController!.setZoomLevel(targetZoom);
      _currentZoomLevel = targetZoom;

      debugPrint(
        'Initial zoom set to: $_currentZoomLevel '
            '(target was ${_config.targetInitialZoom})',
      );
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

    await triggerCenterFocus();
  }

  Future<void> triggerCenterFocus() async {
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

  Future<void> setFocusMode(FocusMode mode) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.setFocusMode(mode);
    } catch (e) {
      debugPrint('Set focus mode error: $e');
    }
  }

  Future<void> setZoomNormalized(double normalizedLevel) async {
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

  Future<void> startImageStream(
      void Function(CameraImage image) onImage,
      ) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startImageStream(onImage);
    } catch (e) {
      debugPrint('Start image stream error: $e');
      rethrow;
    }
  }

  Future<void> stopImageStream() async {
    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Stop image stream error: $e');
    }
  }

  Future<String?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      return imageFile.path;
    } catch (e) {
      debugPrint('Take picture error: $e');
      return null;
    }
  }

  InputImage? convertCameraImage(CameraImage image) {
    try {
      final camera = _cameras?.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      if (camera == null) return null;

      final rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );
      if (rotation == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);

      if (image.planes.isEmpty) return null;

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

  Future<void> dispose() async {
    _isDisposed = true;
    await stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
    _cameras = null;
  }
}

class CameraInitResult {
  final bool isSuccess;
  final String? errorMessage;
  final bool isPermissionDenied;
  final bool isCameraUnavailable;

  const CameraInitResult._({
    required this.isSuccess,
    this.errorMessage,
    this.isPermissionDenied = false,
    this.isCameraUnavailable = false,
  });

  factory CameraInitResult.success() {
    return const CameraInitResult._(isSuccess: true);
  }

  factory CameraInitResult.failure(
      String message, {
        bool isPermissionDenied = false,
        bool isCameraUnavailable = false,
      }) {
    return CameraInitResult._(
      isSuccess: false,
      errorMessage: message,
      isPermissionDenied: isPermissionDenied,
      isCameraUnavailable: isCameraUnavailable,
    );
  }
}