import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';

class SpeedometerLoader extends StatefulWidget {
  final double size;
  final Color color;

  const SpeedometerLoader({
    super.key,
    this.size = 50.0,
    this.color = AppColors.primaryBlack,
  });

  @override
  State<SpeedometerLoader> createState() => _SpeedometerLoaderState();
}

class _SpeedometerLoaderState extends State<SpeedometerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpeedometerPainter(
              percentage: _animation.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _SpeedometerPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintArc = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      startAngle,
      sweepAngle,
      false,
      paintArc,
    );

    final paintNeedle = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    final currentAngle = startAngle + (sweepAngle * percentage);

    final needleEndX = center.dx + (radius - 6) * math.cos(currentAngle);
    final needleEndY = center.dy + (radius - 6) * math.sin(currentAngle);

    canvas.drawLine(center, Offset(needleEndX, needleEndY), paintNeedle);

    canvas.drawCircle(center, 4.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}