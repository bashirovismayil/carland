import 'package:flutter/material.dart';

class OdometerAnimation extends StatefulWidget {
  final int value;
  final int digits;
  final double digitHeight;
  final double digitWidth;
  final TextStyle textStyle;

  const OdometerAnimation({
    super.key,
    required this.value,
    this.digits = 6,
    this.digitHeight = 32,
    this.digitWidth = 20,
    this.textStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  });

  @override
  State<OdometerAnimation> createState() => _OdometerAnimationState();
}

class _OdometerAnimationState extends State<OdometerAnimation> {
  late List<int> _previousDigits;
  late List<int> _currentDigits;

  @override
  void initState() {
    super.initState();
    _currentDigits = _getDigits(widget.value);
    _previousDigits = List.filled(widget.digits, 0);
  }

  @override
  void didUpdateWidget(OdometerAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        _previousDigits = _currentDigits;
        _currentDigits = _getDigits(widget.value);
      });
    }
  }

  List<int> _getDigits(int value) {
    final valueStr = value.toString().padLeft(widget.digits, '0');
    return valueStr.split('').map((e) => int.parse(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.digits,
              (index) => _DigitRoller(
            digit: _currentDigits[index],
            previousDigit: _previousDigits[index],
            height: widget.digitHeight,
            width: widget.digitWidth,
            textStyle: widget.textStyle,
          ),
        ),
      ),
    );
  }
}

class _DigitRoller extends StatefulWidget {
  final int digit;
  final int previousDigit;
  final double height;
  final double width;
  final TextStyle textStyle;

  const _DigitRoller({
    required this.digit,
    required this.previousDigit,
    required this.height,
    required this.width,
    required this.textStyle,
  });

  @override
  State<_DigitRoller> createState() => _DigitRollerState();
}

class _DigitRollerState extends State<_DigitRoller>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.digit != widget.previousDigit) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(_DigitRoller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          int diff = (widget.digit - widget.previousDigit) % 10;
          if (diff < 0) diff += 10;

          final offset = _animation.value * diff * widget.height;

          return ClipRect(
            child: Stack(
              children: List.generate(
                diff + 1,
                    (index) {
                  final displayDigit =
                      (widget.previousDigit + index) % 10;
                  final yOffset = -offset + (index * widget.height);

                  return Positioned(
                    top: yOffset,
                    left: 0,
                    right: 0,
                    height: widget.height,
                    child: Center(
                      child: Text(
                        '$displayDigit',
                        style: widget.textStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}