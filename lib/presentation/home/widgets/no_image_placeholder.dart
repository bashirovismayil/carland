import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';

class NoImagePlaceholder extends StatelessWidget {
  const NoImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Image.asset(
                'assets/png/placeholder_car_photo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(
            AppTranslation.translate(AppStrings.noImage),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
