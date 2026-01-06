import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/enums/enums.dart';
import '../../data/remote/services/local/language_local_service.dart';
import '../../utils/di/locator.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final _languageService = locator<LanguageLocalService>();

  LanguageCubit() : super(LanguageState.initial()) {
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final languageCode = _languageService.currentLanguage;
    final language = AppLanguage.fromCode(languageCode);
    emit(LanguageState(
      currentLanguage: language,
      locale: language.locale,
    ));
  }

  Future<void> changeLanguage(AppLanguage language) async {
    try {
      emit(state.copyWith(isLoading: true));

      await _languageService.setLanguage(language.code);

      emit(LanguageState(
        currentLanguage: language,
        locale: language.locale,
        isLoading: false,
        hasLanguageBeenSelected: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Dil dəyişdirilərkən xəta baş verdi',
      ));
    }
  }

  String get currentLanguageCode => state.currentLanguage.code;
}
