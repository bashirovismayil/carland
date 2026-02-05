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
    final widgets = [
      Text(
        context.currentLanguage(isAzerbaijani ? AppStrings.carcat : AppStrings.welcomeTo),
        style: TextStyle(
          fontSize: 24,
          fontWeight: isAzerbaijani ? FontWeight.w700 : FontWeight.w500,
          color: Colors.black,
        ),
      ),
      Text(
        context.currentLanguage(isAzerbaijani ? AppStrings.welcomeTo : AppStrings.carcat),
        style: TextStyle(
          fontSize: 24,
          fontWeight: isAzerbaijani ? FontWeight.w500 : FontWeight.w700,
          color: Colors.black,
        ),
      ),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.0,
      runSpacing: 4.0,
      children: widgets,
    );
  }
}