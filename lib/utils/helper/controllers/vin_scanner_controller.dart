import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../utils/helper/vin/vin_scanner_service.dart';
import '../../../presentation/vin/widgets/vin_scanner_state.dart';

class VinScannerController {
  final VinScannerService scannerService;
  final void Function(String vin) onVinDetected;
  VoidCallback onStateChanged;

  VinScannerState _state = const VinScannerState();
  VinScannerState get state => _state;

  VinScannerController({
    required this.scannerService,
    required this.onVinDetected,
    required this.onStateChanged,
  });

  Future<void> checkPermissionAndInitialize() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      _updateState(_state.copyWith(hasPermission: true));
      await _initializeScanner();
    } else if (status.isPermanentlyDenied) {
      _updateState(_state.copyWith(
        permissionDenied: true,
        errorMessage: 'Camera permission permanently denied',
      ));
    } else {
      await _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    final result = await Permission.camera.request();

    if (result.isGranted) {
      _updateState(_state.copyWith(hasPermission: true));
      await _initializeScanner();
    } else {
      _updateState(_state.copyWith(
        permissionDenied: true,
        errorMessage: result.isPermanentlyDenied
            ? 'Camera permission permanently denied'
            : 'Camera permission denied',
      ));
    }
  }

  Future<void> _initializeScanner() async {
    _updateState(_state.copyWith(clearError: true));

    final error = await scannerService.initialize();

    if (error != null) {
      _updateState(_state.copyWith(errorMessage: error.errorMessage));
      return;
    }

    _updateState(_state.copyWith(isInitialized: true));
    startContinuousScanning();
  }

  void startContinuousScanning() {
    if (!_state.isInitialized) return;

    _updateState(_state.copyWith(isScanning: true));

    scannerService.startContinuousScanning((result) {
      if (result.isSuccess && result.vin != null) {
        HapticFeedback.heavyImpact();
        scannerService.stopContinuousScanning();
        onVinDetected(result.vin!);
      }
    });
  }

  Future<void> handleTapToFocus(Offset point, Size previewSize) async {
    if (!_state.isInitialized) return;

    _updateState(_state.copyWith(
      focusPoint: point,
      showFocusIndicator: true,
    ));

    await scannerService.setFocusPoint(point, previewSize);
    HapticFeedback.lightImpact();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _updateState(_state.copyWith(showFocusIndicator: false));
    });
  }

  Future<void> toggleFlash() async {
    final isOn = await scannerService.toggleFlash();
    _updateState(_state.copyWith(isFlashOn: isOn));
  }

  void handleLifecycleChange(AppLifecycleState lifecycleState) {
    if (!_state.isInitialized) return;

    if (lifecycleState == AppLifecycleState.inactive) {
      scannerService.stopContinuousScanning();
      scannerService.cameraController?.dispose();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      checkPermissionAndInitialize();
    }
  }

  void clearError() {
    _updateState(_state.copyWith(clearError: true));
  }

  void _updateState(VinScannerState newState) {
    _state = newState;
    onStateChanged();
  }

  void dispose() {
    scannerService.dispose();
  }
}
