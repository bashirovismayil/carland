import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';

class ScanningIndicator extends StatelessWidget {
  const ScanningIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          AppTranslation.translate(AppStrings.vinSearch),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
