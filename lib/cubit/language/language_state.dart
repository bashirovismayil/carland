import 'package:flutter/material.dart';
import '../../core/constants/enums/enums.dart';

class LanguageState {
  final AppLanguage currentLanguage;
  final Locale locale;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLanguageBeenSelected;

  const LanguageState({
    required this.currentLanguage,
    required this.locale,
    this.isLoading = false,
    this.errorMessage,
    this.hasLanguageBeenSelected = false,
  });

  factory LanguageState.initial() {
    return const LanguageState(
      currentLanguage: AppLanguage.azerbaijani,
      locale: Locale('az', 'AZ'),
      isLoading: false,
    );
  }

  LanguageState copyWith({
    AppLanguage? currentLanguage,
    Locale? locale,
    bool? isLoading,
    String? errorMessage,
    bool? hasLanguageBeenSelected,
  }) {
    return LanguageState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasLanguageBeenSelected: hasLanguageBeenSelected ?? this.hasLanguageBeenSelected,
    );
  }

  List<Object?> get props => [currentLanguage, locale, isLoading, errorMessage];
}
