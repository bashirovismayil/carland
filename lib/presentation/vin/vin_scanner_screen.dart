import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../utils/helper/vin/vin_scanner_service.dart';
import '../../utils/helper/controllers/vin_scanner_controller.dart';
import '../../utils/helper/vin_navigation_helper.dart';
import 'widgets/camera_layer.dart';
import 'widgets/scanner_ui_layer.dart';

class VinScannerScreen extends StatefulWidget {
  final bool showManualEntry;

  const VinScannerScreen({
    super.key,
    this.showManualEntry = true,
  });

  @override
  State<VinScannerScreen> createState() => _VinScannerScreenState();
}

class _VinScannerScreenState extends State<VinScannerScreen>
    with WidgetsBindingObserver {
  late final VinScannerController _controller;
  late final VinScannerService _scannerService;

  @override
  void initState() {
    super.initState();
    _scannerService = VinScannerService();
    _controller = VinScannerController(
      scannerService: _scannerService,
      onVinDetected: _handleVinDetected,
      onStateChanged: _onStateChanged,
    );
    WidgetsBinding.instance.addObserver(this);
    _controller.checkPermissionAndInitialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.handleLifecycleChange(state);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _handleVinDetected(String vin) {
    VinNavigationHelper.navigateWithLoading(context, vin);
  }

  void _handleTapToFocus(TapDownDetails details) {
    final size = MediaQuery.of(context).size;
    _controller.handleTapToFocus(details.localPosition, size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: GestureDetector(
        onTapDown: _controller.state.isInitialized ? _handleTapToFocus : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraLayer(
              state: _controller.state,
              cameraController: _scannerService.cameraController,
              onToggleFlash: _controller.toggleFlash,
              onRequestPermission: _controller.checkPermissionAndInitialize,
            ),
            ScannerUILayer(state: _controller.state),
          ],
        ),
      ),
    );
  }
}
