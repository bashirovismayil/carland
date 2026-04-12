import 'dart:math' as math;
import 'package:flutter/material.dart';

mixin PeekHintMixin<T extends StatefulWidget> on State<T> {
  late AnimationController _peekHintController;
  late Animation<double> _peekHintAnimation;
  bool _peekHintPlayed = false;
  bool get peekHintPlayed => _peekHintPlayed;
  bool get isPeekAnimating => _peekHintController.isAnimating;
  Animation<double> get peekHintAnimation => _peekHintAnimation;

  void initPeekHint({
    required TickerProvider vsync,
    double maxAngle = 15.0,
    Duration duration = const Duration(milliseconds: 900),
  }) {
    _peekHintController = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    _peekHintAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: maxAngle)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: maxAngle, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_peekHintController);
  }

  void triggerPeekHint() {
    if (_peekHintPlayed) return;
    _peekHintPlayed = true;
    _peekHintController.forward(from: 0.0);
  }

  void cancelPeekHint() {
    if (_peekHintController.isAnimating) {
      _peekHintController.reset();
    }
  }

  void disposePeekHint() {
    _peekHintController.dispose();
  }

  Widget buildPeekHintTransform({required Widget child}) {
    return AnimatedBuilder(
      animation: _peekHintAnimation,
      builder: (context, _) {
        final angle = _peekHintAnimation.value * (math.pi / 180);
        if (angle == 0.0) return child;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: child,
        );
      },
    );
  }
}
