import 'package:flutter/material.dart';
import 'package:carcat/core/constants/colors/app_colors.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/presentation/auth/auth_page.dart';
import 'package:carcat/utils/di/locator.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:carcat/data/remote/services/local/login_local_services.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        AppTranslation.translate(AppStrings.logout),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        AppTranslation.translate(AppStrings.areYouSureYouWantToLogOut),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.red,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppTranslation.translate(AppStrings.cancel),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            locator<LoginLocalService>().logout();

            if (context.mounted) {
              Go.replaceAndRemove(context, AuthPage());
            }
          },
          child: Text(
            AppTranslation.translate(AppStrings.logout),
            style: TextStyle(
              color: AppColors.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}