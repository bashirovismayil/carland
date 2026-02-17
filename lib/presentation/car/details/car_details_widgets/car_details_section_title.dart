import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/localization/app_translation.dart';

class CarDetailsSectionTitle extends StatelessWidget {
  const CarDetailsSectionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlack,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Text(
          AppTranslation.translate(AppStrings.addCarDetails),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}