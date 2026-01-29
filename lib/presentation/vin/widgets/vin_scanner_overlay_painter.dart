import 'package:flutter/material.dart';

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

    _drawOverlay(canvas, size, scanRect);
    _drawCorners(canvas, scanRect);
  }

  void _drawOverlay(Canvas canvas, Size size, Rect scanRect) {
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, Radius.circular(cornerRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, Paint()..color = overlayColor);
  }

  void _drawCorners(Canvas canvas, Rect scanRect) {
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

  void _drawCorner(Canvas canvas, Paint paint, Offset corner, bool isLeft, bool isTop) {
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
