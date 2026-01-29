import 'package:flutter/material.dart';

class VinScannerState {
  final bool isInitialized;
  final bool isScanning;
  final bool isFlashOn;
  final bool hasPermission;
  final bool permissionDenied;
  final String? errorMessage;
  final Offset? focusPoint;
  final bool showFocusIndicator;

  const VinScannerState({
    this.isInitialized = false,
    this.isScanning = false,
    this.isFlashOn = false,
    this.hasPermission = false,
    this.permissionDenied = false,
    this.errorMessage,
    this.focusPoint,
    this.showFocusIndicator = false,
  });

  VinScannerState copyWith({
    bool? isInitialized,
    bool? isScanning,
    bool? isFlashOn,
    bool? hasPermission,
    bool? permissionDenied,
    String? errorMessage,
    Offset? focusPoint,
    bool? showFocusIndicator,
    bool clearError = false,
    bool clearFocusPoint = false,
  }) {
    return VinScannerState(
      isInitialized: isInitialized ?? this.isInitialized,
      isScanning: isScanning ?? this.isScanning,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      hasPermission: hasPermission ?? this.hasPermission,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      focusPoint: clearFocusPoint ? null : (focusPoint ?? this.focusPoint),
      showFocusIndicator: showFocusIndicator ?? this.showFocusIndicator,
    );
  }
}
