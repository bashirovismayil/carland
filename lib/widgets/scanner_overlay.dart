import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final double scanAreaWidth;
  final double scanAreaHeight;
  final double cornerLength;
  final double cornerRadius;
  final double strokeWidth;
  final Color overlayColor;
  final Color frameColor;

  ScannerOverlayPainter({
    required this.scanAreaWidth,
    required this.scanAreaHeight,
    this.cornerLength = 32.0,
    this.cornerRadius = 16.0,
    this.strokeWidth = 4.0,
    this.overlayColor = const Color(0x99000000),
    this.frameColor = const Color(0xFF1A1A1A),
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

    _drawCorner(canvas, cornerPaint, scanRect.topLeft, cornerLength,
        cornerRadius, true, true);
    _drawCorner(canvas, cornerPaint, scanRect.topRight, cornerLength,
        cornerRadius, false, true);
    _drawCorner(canvas, cornerPaint, scanRect.bottomLeft, cornerLength,
        cornerRadius, true, false);
    _drawCorner(canvas, cornerPaint, scanRect.bottomRight, cornerLength,
        cornerRadius, false, false);
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset corner, double length,
      double radius, bool isLeft, bool isTop) {
    final path = Path();

    final xDir = isLeft ? 1.0 : -1.0;
    final yDir = isTop ? 1.0 : -1.0;

    path.moveTo(corner.dx + (length * xDir), corner.dy);
    path.lineTo(corner.dx + (radius * xDir), corner.dy);

    path.arcToPoint(
      Offset(corner.dx, corner.dy + (radius * yDir)),
      radius: Radius.circular(radius),
      clockwise: isLeft != isTop,
    );

    path.lineTo(corner.dx, corner.dy + (length * yDir));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return scanAreaWidth != oldDelegate.scanAreaWidth ||
        scanAreaHeight != oldDelegate.scanAreaHeight;
  }
}

class ScannerOverlay extends StatelessWidget {
  final double scanAreaWidth;
  final double scanAreaHeight;

  const ScannerOverlay({
    super.key,
    required this.scanAreaWidth,
    required this.scanAreaHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        scanAreaWidth: scanAreaWidth,
        scanAreaHeight: scanAreaHeight,
      ),
      child: const SizedBox.expand(),
    );
  }
}
