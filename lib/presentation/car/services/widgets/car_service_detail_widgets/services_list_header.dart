import 'package:flutter/material.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';

class ServicesListHeader extends StatelessWidget {
  final bool isLoading;

  const ServicesListHeader({
    super.key,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslation.translate(AppStrings.schedule),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: See all
                },
                child: Text(
                  AppTranslation.translate(AppStrings.seeAll),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: AppColors.primaryBlack,
              minHeight: 2,
            ),
        ],
      ),
    );
  }
}
