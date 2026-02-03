import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';

class ServicesEmptyState extends StatelessWidget {
  final bool isAddNewCarSelected;

  const ServicesEmptyState({
    super.key,
    required this.isAddNewCarSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isAddNewCarSelected) {
      return _buildAddCarPlaceholder();
    }
    return _buildNoServicesPlaceholder();
  }

  Widget _buildAddCarPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 55,),
            SvgPicture.asset(
              "assets/svg/barcode_transparent.svg",
              width: 50,
              height: 50,
              colorFilter: ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslation.translate(AppStrings.serviceInfoWillAppear),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoServicesPlaceholder() {
    return Center(
      child: Text(
        AppTranslation.translate(AppStrings.noServicesFound),
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
