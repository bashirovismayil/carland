import 'dart:math';
import 'package:flutter/material.dart';

class CircularPercentageChart extends StatefulWidget {
  final int percentage;
  final double size;
  final double strokeWidth;
  final Color Function(int percentage) getColor;
  final Duration animationDuration;
  final String? label;
  final String? alertText;
  final Duration alertInterval;

  const CircularPercentageChart({
    super.key,
    required this.percentage,
    this.size = 80,
    this.strokeWidth = 7,
    required this.getColor,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.label,
    this.alertText,
    this.alertInterval = const Duration(seconds: 2),
  });

  @override
  State<CircularPercentageChart> createState() =>
      _CircularPercentageChartState();
}

class _CircularPercentageChartState extends State<CircularPercentageChart>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  AnimationController? _alertFadeController;
  bool _showAlertText = false;
  bool _alertActive = false;

  bool get _shouldAlert =>
      widget.percentage <= 0 && widget.alertText != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    if (_shouldAlert) {
      _startAlertCycle();
    }
  }

  void _startAlertCycle() {
    if (_alertActive) return;
    _alertActive = true;

    _alertFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scheduleNextToggle();
  }

  void _scheduleNextToggle() {
    Future.delayed(widget.alertInterval, () {
      if (!mounted || !_alertActive) return;

      if (_showAlertText) {
        _alertFadeController!.reverse().then((_) {
          if (!mounted) return;
          setState(() => _showAlertText = false);
          _scheduleNextToggle();
        });
      } else {
        // Fade in alert text
        setState(() => _showAlertText = true);
        _alertFadeController!.forward().then((_) {
          if (!mounted) return;
          _scheduleNextToggle();
        });
      }
    });
  }

  void _stopAlertCycle() {
    _alertActive = false;
    _alertFadeController?.dispose();
    _alertFadeController = null;
    _showAlertText = false;
  }

  @override
  void didUpdateWidget(CircularPercentageChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }

    if (_shouldAlert && !_alertActive) {
      _startAlertCycle();
    } else if (!_shouldAlert && _alertActive) {
      _stopAlertCycle();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _alertFadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPercentage = _animation.value.toInt();
        final color = widget.getColor(currentPercentage);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _CircularChartPainter(
              percentage: _animation.value,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(
              child: _shouldAlert
                  ? _buildAlertContent(color)
                  : _buildNormalContent(currentPercentage, color),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNormalContent(int currentPercentage, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$currentPercentage%',
          style: TextStyle(
            fontSize: widget.size * 0.22,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.1,
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 1),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: widget.size * 0.135,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAlertContent(Color color) {
    final fadeAnim = _alertFadeController!;

    return AnimatedBuilder(
      animation: fadeAnim,
      builder: (context, _) {
        final t = fadeAnim.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1.0 - t).clamp(0.0, 1.0),
              child: Text(
                '0%',
                style: TextStyle(
                  fontSize: widget.size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.1,
                ),
              ),
            ),
            Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.alertText!,
                  style: TextStyle(
                    fontSize: widget.size * 0.135,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CircularChartPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;

  _CircularChartPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}