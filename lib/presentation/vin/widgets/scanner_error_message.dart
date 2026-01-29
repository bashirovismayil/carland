import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/values/app_theme.dart';

class ScannerErrorMessage extends StatelessWidget {
  final String message;

  const ScannerErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
