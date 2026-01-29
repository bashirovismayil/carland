import 'package:carcat/presentation/vin/widgets/vin_scanner_overlay_painter.dart';
import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scanAreaWidth = constraints.maxWidth * 0.85;
          final scanAreaHeight = scanAreaWidth * 0.25;

          return CustomPaint(
            painter: VinScannerOverlayPainter(
              scanAreaWidth: scanAreaWidth,
              scanAreaHeight: scanAreaHeight,
              overlayColor: Colors.white.withOpacity(0.92),
              frameColor: const Color(0xFF2A2A2A),
              cornerLength: 24,
              cornerRadius: 10,
              strokeWidth: 3.5,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
