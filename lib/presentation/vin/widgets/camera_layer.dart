import 'package:camera/camera.dart';
import 'package:carcat/presentation/vin/widgets/vin_scanner_state.dart';
import 'package:flutter/material.dart';
import '../../../core/mixins/scan_line_animation_mixin.dart';
import 'camera_loading_view.dart';
import 'flash_button.dart';
import 'focus_indicator.dart';
import 'full_screen_camera.dart';
import 'permission_request_view.dart';
import 'scan_line_overlay.dart';
import 'scanner_overlay.dart';

class CameraLayer extends StatefulWidget {
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
  State<CameraLayer> createState() => _CameraLayerState();
}

class _CameraLayerState extends State<CameraLayer>
    with SingleTickerProviderStateMixin, ScanLineMixin {
  @override
  void initState() {
    super.initState();
    initScanLineController();
  }

  @override
  void dispose() {
    disposeScanLineController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCameraOrPlaceholder(),
        if (widget.state.hasPermission) const ScannerOverlay(),
        if (widget.state.hasPermission && widget.state.isScanning)
          ScanLineOverlay(animation: scanLineAnimation),
        if (widget.state.hasPermission && widget.state.isInitialized)
          _buildFlashButton(context),
        if (widget.state.showFocusIndicator && widget.state.focusPoint != null)
          _buildFocusIndicator(),
      ],
    );
  }

  Widget _buildCameraOrPlaceholder() {
    if (widget.state.hasPermission && widget.state.isInitialized) {
      return FullScreenCamera(controller: widget.cameraController);
    }
    if (!widget.state.hasPermission) {
      return PermissionRequestView(
        permissionDenied: widget.state.permissionDenied,
        onRequestPermission: widget.onRequestPermission,
      );
    }
    return const CameraLoadingView();
  }

  Widget _buildFlashButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scanAreaWidth = screenWidth * 0.85;
    final scanAreaHeight = scanAreaWidth * 0.25;
    final scanCenterY = screenHeight / 2;
    final scanRight = (screenWidth + scanAreaWidth) / 2;

    return Positioned(
      top: scanCenterY + scanAreaHeight / 2 + 30,
      left: scanRight - 44,
      child: FlashButton(
        isFlashOn: widget.state.isFlashOn,
        onPressed: widget.onToggleFlash,
      ),
    );
  }

  Widget _buildFocusIndicator() {
    return Positioned(
      left: widget.state.focusPoint!.dx - 30,
      top: widget.state.focusPoint!.dy - 30,
      child: const FocusIndicator(),
    );
  }
}
