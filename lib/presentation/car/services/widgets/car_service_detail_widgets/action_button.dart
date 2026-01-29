import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const ActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppColors.primaryBlack,
          border: outlined
              ? Border.all(color: AppColors.primaryBlack, width: 1)
              : null,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: outlined ? AppColors.primaryBlack : Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
