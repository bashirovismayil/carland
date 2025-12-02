import 'package:flutter/material.dart';
import '../../data/remote/services/local/language_local_service.dart';
import '../../utils/helper/app_localization.dart';
import '../../utils/di/locator.dart';
import '../../utils/helper/translation.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;

  String currentLanguage(String key) => loc.translate(key);
}

class AppTranslation {
  static String translate(String key) {
    try {
      final currentLang = locator<LanguageLocalService>().currentLanguage;

      return Translations.translate(key, currentLang);
    } catch (e) {
      return key;
    }
  }
}