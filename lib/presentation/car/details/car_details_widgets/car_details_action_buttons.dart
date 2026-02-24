import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../presentation/user/user_main_nav.dart';
import '../../../../widgets/custom_button.dart';

class SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.isSubmitting,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      height: 58,
      onPressed: isSubmitting ? null : onPressed,
      backgroundColor: AppColors.primaryBlack,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      elevation: 0,
      child: isSubmitting
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 20),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            AppTranslation.translate(AppStrings.addButton),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      height: 58,
      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UserMainNavigationPage()),
            (route) => false,
      ),
      backgroundColor: AppColors.lightGrey,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppTranslation.translate(AppStrings.cancel),
            style: const TextStyle(
              color: AppColors.primaryBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}