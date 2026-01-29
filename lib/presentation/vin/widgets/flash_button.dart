import 'package:flutter/material.dart';

class FlashButton extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onPressed;

  const FlashButton({
    super.key,
    required this.isFlashOn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: isFlashOn ? Colors.yellow : Colors.white,
          size: 22,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
