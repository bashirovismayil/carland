import 'package:flutter/material.dart';

mixin ScanLineMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;

  Animation<double> get scanLineAnimation => _scanLineAnimation;
  AnimationController get scanLineController => _scanLineController;

  @mustCallSuper
  void initScanLineController() {
    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );

    _scanLineController.repeat(reverse: true);
  }

  @mustCallSuper
  void disposeScanLineController() {
    _scanLineController.dispose();
  }
}