import 'package:camera/camera.dart';
import 'package:carcat/presentation/vin/widgets/vin_scanner_state.dart';
import 'package:flutter/material.dart';
import 'camera_loading_view.dart';
import 'flash_button.dart';
import 'focus_indicator.dart';
import 'full_screen_camera.dart';
import 'permission_request_view.dart';
import 'scanner_overlay.dart';

class CameraLayer extends StatelessWidget {
  final VinScannerState state;
  final CameraController? cameraController;
  final VoidCallback onToggleFlash;
  final VoidCallback onRequestPermission;

  const CameraLayer({
    super.key,
    required this.state,
    required this.cameraController,
    required this.onToggleFlash,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCameraOrPlaceholder(),
        if (state.hasPermission && state.isInitialized) _buildFlashButton(context),
        if (state.hasPermission) const ScannerOverlay(),
        if (state.showFocusIndicator && state.focusPoint != null)
          _buildFocusIndicator(),
      ],
    );
  }

  Widget _buildCameraOrPlaceholder() {
    if (state.hasPermission && state.isInitialized) {
      return FullScreenCamera(controller: cameraController);
    }
    if (!state.hasPermission) {
      return PermissionRequestView(
        permissionDenied: state.permissionDenied,
        onRequestPermission: onRequestPermission,
      );
    }
    return const CameraLoadingView();
  }

  Widget _buildFlashButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 20,
      child: FlashButton(
        isFlashOn: state.isFlashOn,
        onPressed: onToggleFlash,
      ),
    );
  }

  Widget _buildFocusIndicator() {
    return Positioned(
      left: state.focusPoint!.dx - 30,
      top: state.focusPoint!.dy - 30,
      child: const FocusIndicator(),
    );
  }
}
