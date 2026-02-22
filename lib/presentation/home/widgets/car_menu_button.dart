import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';

class CarMenuButton extends StatelessWidget {
  final VoidCallback onDelete;

  const CarMenuButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.more_vert,
          color: AppColors.textPrimary,
          size: 25,
        ),
        onPressed: onDelete,
      ),
    );
  }
}