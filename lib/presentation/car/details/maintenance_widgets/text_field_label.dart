import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';

class TextFieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const TextFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.errorColor,
            ),
          ),
      ],
    );
  }
}
