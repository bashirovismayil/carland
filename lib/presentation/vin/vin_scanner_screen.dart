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
      body: _scannedVin != null ? _buildSuccessScreen() : _buildScannerScreen(),
    );
  }

  Widget _buildScannerScreen() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Full screen camera
        if (_hasPermission && _isInitialized)
          _buildFullScreenCamera()
        else if (!_hasPermission)
          Container(color: Colors.black, child: _buildPermissionRequest())
        else
          Container(color: Colors.black, child: _buildLoadingView()),

        // Layer 2: Tap to focus gesture (full screen)
        if (_isInitialized && _hasPermission)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 -
                (MediaQuery.of(context).size.width * 0.7 / 2) -
                MediaQuery.of(context).padding.top - 20,
            right: MediaQuery.of(context).size.width * 0.15 - 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: _isFlashOn ? Colors.yellow : Colors.white,
                  size: 20,
                ),
                onPressed: _toggleFlash,
                padding: EdgeInsets.zero,
              ),
            ),
          ),

        // Layer 3: White overlay with scan window cutout
        if (_hasPermission)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scanAreaSize = constraints.maxWidth * 0.5;

                return CustomPaint(
                  painter: VinScannerOverlayPainter(
                    scanAreaWidth: scanAreaSize,
                    scanAreaHeight: scanAreaSize,
                    overlayColor: Colors.white.withOpacity(0.92),
                    frameColor: const Color(0xFF2A2A2A),
                    cornerLength: 28,
                    cornerRadius: 12,
                    strokeWidth: 3.5,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),

        // Layer 4: Focus indicator
        if (_showFocusIndicator && _focusPoint != null)
          Positioned(
            left: _focusPoint!.dx - 30,
            top: _focusPoint!.dy - 30,
            child: _buildFocusIndicator(),
          ),

        // Layer 5: UI Elements (header, text, buttons)
        SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingXl),
              _buildTitleSection(),
              const Spacer(),
              if (_errorMessage != null) _buildErrorMessage(),
              if (_isScanning && _isContinuousMode) _buildScanningIndicator(),
              _buildBottomSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenCamera() {
    final controller = _scannerService.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1,
          height: controller.value.previewSize?.width ?? 1,
          child: CameraPreview(controller),
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
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Text(
            'Add your Car VIN',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        children: [
          const Text(
            'Scan Car VIN Number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Use your car\'s Vehicle Identification Number (VIN) to fetch accurate details. You can type it in or scan via camera.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashButtonRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            _isFlashOn ? Icons.flash_on : Icons.flash_off,
            color: _isFlashOn ? Colors.yellow : Colors.white,
            size: 24,
          ),
          onPressed: _toggleFlash,
        ),
      ),
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

  Widget _buildScanningIndicator() {
    return Padding(
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
    );
  }

  Widget _buildSuccessScreen() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          if (!_isContinuousMode)
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

    // Draw overlay with cutout for scan area
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
          RRect.fromRectAndRadius(scanRect, Radius.circular(cornerRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, Paint()..color = overlayColor);

    // Draw corner brackets
    final cornerPaint = Paint()
      ..color = frameColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawCorner(canvas, cornerPaint, scanRect.topLeft, true, true);
    _drawCorner(canvas, cornerPaint, scanRect.topRight, false, true);
    _drawCorner(canvas, cornerPaint, scanRect.bottomLeft, true, false);
    _drawCorner(canvas, cornerPaint, scanRect.bottomRight, false, false);
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