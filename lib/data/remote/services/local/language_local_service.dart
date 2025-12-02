import 'package:hive/hive.dart';

class LanguageLocalService {
  final Box<String> _box;

  LanguageLocalService(this._box);

  static const String defaultLanguage = 'en';
  static const String _languageKey = 'selected_language';

  String get currentLanguage {
    return _box.get(_languageKey, defaultValue: defaultLanguage) ?? defaultLanguage;
  }

  Future<void> setLanguage(String languageCode) async {
    await _box.put(_languageKey, languageCode);
  }

  Future<void> clearLanguage() async {
    await _box.delete(_languageKey);
  }

  bool get hasLanguage {
    return _box.containsKey(_languageKey);
  }
}