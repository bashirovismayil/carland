import 'package:camera/camera.dart';
import 'package:carcat/core/constants/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/values/app_theme.dart';
import '../../data/remote/services/local/vin_scanner_service.dart';

class VinScannerScreen extends StatefulWidget {
  final void Function(String vin)? onVinScanned;
  final bool showManualEntry;

  const VinScannerScreen({
    super.key,
    this.onVinScanned,
    this.showManualEntry = true,
  });

  @override
  State<VinScannerScreen> createState() => _VinScannerScreenState();
}

class _VinScannerScreenState extends State<VinScannerScreen>
    with WidgetsBindingObserver {
  late final VinScannerService _scannerService;

  bool _isInitialized = false;
  bool _isScanning = false;
  final bool _isContinuousMode = true;
  bool _isFlashOn = false;
  bool _hasPermission = false;
  bool _permissionDenied = false;

  String? _scannedVin;
  String? _errorMessage;
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  @override
  void initState() {
    super.initState();
    _scannerService = VinScannerService();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInitialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _scannerService.stopContinuousScanning();
      _scannerService.cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _checkPermissionAndInitialize();
    }
  }

  Future<void> _checkPermissionAndInitialize() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      _hasPermission = true;
      await _initializeScanner();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _permissionDenied = true;
        _errorMessage = 'Camera permission permanently denied';
      });
    } else {
      final result = await Permission.camera.request();

      if (result.isGranted) {
        _hasPermission = true;
        await _initializeScanner();
      } else {
        setState(() {
          _permissionDenied = true;
          _errorMessage = result.isPermanentlyDenied
              ? 'Camera permission permanently denied'
              : 'Camera permission denied';
        });
      }
    }
  }

  Future<void> _initializeScanner() async {
    setState(() {
      _errorMessage = null;
    });

    final error = await _scannerService.initialize();

    if (error != null) {
      setState(() {
        _errorMessage = error.errorMessage;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      if (_isContinuousMode) {
        _startContinuousScanning();
      }
    }
  }

  void _startContinuousScanning() {
    if (!_isInitialized || _scannedVin != null) return;

    setState(() {
      _isScanning = true;
    });

    _scannerService.startContinuousScanning((result) {
      if (!mounted) return;

      if (result.isSuccess && result.vin != null) {
        HapticFeedback.heavyImpact();

        setState(() {
          _scannedVin = result.vin;
          _isScanning = false;
        });

        _scannerService.stopContinuousScanning();

        if (widget.onVinScanned != null) {
          widget.onVinScanned!(result.vin!);
        }
      }
    });
  }

  void _handleTapToFocus(TapDownDetails details, Size previewSize) async {
    if (!_isInitialized) return;

    final point = details.localPosition;

    setState(() {
      _focusPoint = point;
      _showFocusIndicator = true;
    });

    await _scannerService.setFocusPoint(point, previewSize);

    HapticFeedback.lightImpact();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showFocusIndicator = false;
        });
      }
    });
  }

  Future<void> _manualCapture() async {
    if (_isScanning || !_isInitialized) return;

    await _scannerService.stopContinuousScanning();

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    final result = await _scannerService.captureAndScan();

    if (!mounted) return;

    if (result.isSuccess && result.vin != null) {
      HapticFeedback.heavyImpact();

      setState(() {
        _scannedVin = result.vin;
        _isScanning = false;
      });

      if (widget.onVinScanned != null) {
        widget.onVinScanned!(result.vin!);
      }
    } else {
      setState(() {
        _isScanning = false;
        _errorMessage = result.errorMessage;
      });

      if (_isContinuousMode) {
        _startContinuousScanning();
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _errorMessage == result.errorMessage) {
          setState(() {
            _errorMessage = null;
          });
        }
      });
    }
  }

  Future<void> _toggleFlash() async {
    final isOn = await _scannerService.toggleFlash();
    setState(() {
      _isFlashOn = isOn;
    });
  }

  void _resetScan() {
    setState(() {
      _scannedVin = null;
      _errorMessage = null;
    });

    if (_isContinuousMode) {
      _startContinuousScanning();
    }
  }

  void _confirmVin() {
    if (_scannedVin != null) {
      Navigator.of(context).pop(_scannedVin);
    }
  }

  void _copyVin() {
    if (_scannedVin != null) {
      Clipboard.setData(ClipboardData(text: _scannedVin!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('VIN copied to clipboard'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _scannedVin != null
                  ? _buildSuccessView()
                  : _buildScannerView(),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Text(
            'Add your Car VIN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        const SizedBox(height: AppTheme.spacingLg),
        const Text(
          'Scan Car VIN Number',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
          child: Text(
            'Point camera at the VIN plate. Tap to focus on the text.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Expanded(
          child: _buildCameraPreview(),
        ),
        if (_errorMessage != null) _buildErrorMessage(),

        // Scanning indicator
        if (_isScanning && _isContinuousMode)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Scanning for VIN...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppTheme.spacingMd),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Camera or placeholder
                  if (!_hasPermission)
                    _buildPermissionRequest()
                  else if (!_isInitialized)
                    _buildLoadingView()
                  else
                    _buildCameraView(constraints),

                  // Scanner overlay
                  if (_isInitialized && _hasPermission)
                    _buildScannerOverlay(constraints),

                  // Tap to focus gesture
                  if (_isInitialized && _hasPermission)
                    Positioned.fill(
                      child: GestureDetector(
                        onTapDown: (details) => _handleTapToFocus(
                          details,
                          Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),

                  // Focus indicator
                  if (_showFocusIndicator && _focusPoint != null)
                    Positioned(
                      left: _focusPoint!.dx - 30,
                      top: _focusPoint!.dy - 30,
                      child: _buildFocusIndicator(),
                    ),

                  // Flash button
                  if (_isInitialized && _hasPermission)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildFlashButton(),
                    ),

                  // Zoom slider
                  if (_isInitialized && _hasPermission)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: _buildZoomSlider(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCameraView(BoxConstraints constraints) {
    final controller = _scannerService.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return _buildLoadingView();
    }

    final cameraAspectRatio = controller.value.aspectRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth / cameraAspectRatio,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(BoxConstraints constraints) {
    final scanAreaWidth = constraints.maxWidth - 32;
    final scanAreaHeight = 80.0;

    return CustomPaint(
      painter: VinScannerOverlayPainter(
        scanAreaWidth: scanAreaWidth,
        scanAreaHeight: scanAreaHeight,
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildFocusIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.5, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.yellow, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.center_focus_strong,
                color: Colors.yellow,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoomSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.zoom_out, color: Colors.white70, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white38,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: 0.15, // Default zoom
                min: 0.0,
                max: 0.5, // Max %50 zoom
                onChanged: (value) {
                  _scannerService.setZoom(value);
                },
              ),
            ),
          ),
          const Icon(Icons.zoom_in, color: Colors.white70, size: 18),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _permissionDenied ? Icons.no_photography : Icons.camera_alt,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _permissionDenied
                  ? 'Camera Access Denied'
                  : 'Camera Permission Required',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _permissionDenied
                  ? 'Please enable camera access in settings'
                  : 'We need camera access to scan VIN codes',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _permissionDenied
                  ? () => openAppSettings()
                  : _checkPermissionAndInitialize,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                  _permissionDenied ? 'Open Settings' : 'Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          _isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: _isFlashOn ? Colors.yellow : Colors.white,
          size: 20,
        ),
        onPressed: _toggleFlash,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.successColor,
                size: 48,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              'VIN Scanned Successfully',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _scannedVin!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: _copyVin,
                    color: AppColors.textSecondary,
                    tooltip: 'Copy VIN',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            TextButton.icon(
              onPressed: _resetScan,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Scan Again'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          if (_scannedVin == null && !_isContinuousMode)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed:
                    _isInitialized && !_isScanning ? _manualCapture : null,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : const Icon(Icons.camera_alt, size: 20),
                label: Text(_isScanning ? 'Processing...' : 'Capture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceColor,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
              ),
            ),
          if (_scannedVin != null)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmVin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: const Text(
                  'Use This VIN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VinScannerOverlayPainter extends CustomPainter {
  final double scanAreaWidth;
  final double scanAreaHeight;
  final double cornerLength;
  final double cornerRadius;
  final double strokeWidth;
  final Color overlayColor;
  final Color frameColor;

  VinScannerOverlayPainter({
    required this.scanAreaWidth,
    required this.scanAreaHeight,
    this.cornerLength = 24.0,
    this.cornerRadius = 8.0,
    this.strokeWidth = 3.0,
    this.overlayColor = const Color(0x88000000),
    this.frameColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final scanRect = Rect.fromCenter(
      center: center,
      width: scanAreaWidth,
      height: scanAreaHeight,
    );

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
          RRect.fromRectAndRadius(scanRect, Radius.circular(cornerRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, Paint()..color = overlayColor);

    final cornerPaint = Paint()
      ..color = frameColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawCorner(canvas, cornerPaint, scanRect.topLeft, true, true);
    _drawCorner(canvas, cornerPaint, scanRect.topRight, false, true);
    _drawCorner(canvas, cornerPaint, scanRect.bottomLeft, true, false);
    _drawCorner(canvas, cornerPaint, scanRect.bottomRight, false, false);

    final hintPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(scanRect.left + 8, center.dy),
      Offset(scanRect.right - 8, center.dy),
      hintPaint,
    );
  }

  void _drawCorner(
      Canvas canvas, Paint paint, Offset corner, bool isLeft, bool isTop) {
    final path = Path();

    final xDir = isLeft ? 1.0 : -1.0;
    final yDir = isTop ? 1.0 : -1.0;

    path.moveTo(corner.dx + (cornerLength * xDir), corner.dy);
    path.lineTo(corner.dx + (cornerRadius * xDir), corner.dy);

    path.arcToPoint(
      Offset(corner.dx, corner.dy + (cornerRadius * yDir)),
      radius: Radius.circular(cornerRadius),
      clockwise: isLeft != isTop,
    );

    path.lineTo(corner.dx, corner.dy + (cornerLength * yDir));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
