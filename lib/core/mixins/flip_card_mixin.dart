import 'package:flutter/material.dart';

mixin FlipCardMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  bool _isFlipped = false;
  bool get isFlipped => _isFlipped;

  @mustCallSuper
  void initFlipController() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOut,
      ),
    );

    _flipController.addStatusListener(_onFlipStatus);
  }

  Animation<double> get flipAnimation => _flipAnimation;
  AnimationController get flipController => _flipController;

  void _onFlipStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _isFlipped = true);
    } else if (status == AnimationStatus.dismissed) {
      setState(() => _isFlipped = false);
    }
  }

  void flipCard() {
    if (_flipController.isAnimating) return;
    _flipController.forward();
  }

  void unflipCard() {
    if (_flipController.isAnimating) return;
    _flipController.reverse();
  }

  @mustCallSuper
  void disposeFlipController() {
    _flipController.removeStatusListener(_onFlipStatus);
    _flipController.dispose();
  }
}