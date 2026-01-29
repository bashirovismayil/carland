import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/localization/app_translation.dart';

class ScannerHeader extends StatelessWidget {
  const ScannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: AppTheme.spacingMd),
          Text(
            AppTranslation.translate(AppStrings.addYourCarVin),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.of(context).pop(),
        color: AppColors.mediumGrey,
      ),
    );
  }
}
