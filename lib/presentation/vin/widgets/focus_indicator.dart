import 'package:flutter/material.dart';

class FocusIndicator extends StatelessWidget {
  const FocusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
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
}
