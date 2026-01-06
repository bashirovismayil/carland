import 'package:flutter/material.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../data/remote/services/local/language_local_service.dart';
import '../../../utils/di/locator.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = locator<LanguageLocalService>().currentLanguage;

    final isAzerbaijani = currentLang == 'az';

    if (isAzerbaijani) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.currentLanguage(AppStrings.carcat),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.currentLanguage(AppStrings.welcomeTo),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.currentLanguage(AppStrings.welcomeTo),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          context.currentLanguage(AppStrings.carcat),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}