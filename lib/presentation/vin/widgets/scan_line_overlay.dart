import 'package:flutter/material.dart';

class ScanLineOverlay extends StatelessWidget {
  final Animation<double> animation;

  const ScanLineOverlay({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scanAreaWidth = constraints.maxWidth * 0.85;
          final scanAreaHeight = scanAreaWidth * 0.25;

          final centerY = constraints.maxHeight / 2;
          final scanTop = centerY - (scanAreaHeight / 2);

          const verticalPadding = 6.0;
          final lineTravel = scanAreaHeight - (verticalPadding * 2);

          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final lineY = scanTop + verticalPadding + (lineTravel * animation.value);
              final lineWidth = scanAreaWidth * 0.83;
              final lineLeft = (constraints.maxWidth - lineWidth) / 2;

              return Stack(
                children: [
                  Positioned(
                    left: lineLeft,
                    width: lineWidth,
                    top: lineY,
                    child: Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.35),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}