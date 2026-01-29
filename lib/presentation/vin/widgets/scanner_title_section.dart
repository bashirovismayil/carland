import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/localization/app_translation.dart';

class ScannerTitleSection extends StatelessWidget {
  const ScannerTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        children: [
          Text(
            AppTranslation.translate(AppStrings.scanCarVinNumber),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            AppTranslation.translate(AppStrings.scannerPageSubtitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
