import 'package:flutter/material.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/extensions/auth_extensions/string_validators.dart';

class FormValidators {
  FormValidators._();

  static String? name(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.currentLanguage(AppStrings.nameRequired);
    }
    if (value.trim().length < 2) {
      return context.currentLanguage(AppStrings.nameTooShort);
    }
    if (!value.trim().isAlphabetic) {
      return context.currentLanguage(AppStrings.nameInvalid);
    }
    return null;
  }

  static String? surname(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.currentLanguage(AppStrings.surnameRequired);
    }
    if (value.trim().length < 2) {
      return context.currentLanguage(AppStrings.surnameTooShort);
    }
    if (!StringValidators(value.trim()).isAlphabetic) {
      return context.currentLanguage(AppStrings.surnameInvalid);
    }
    return null;
  }

  static String? phone(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.currentLanguage(AppStrings.phoneRequired);
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 9) {
      return context.currentLanguage(AppStrings.phoneInvalidLength);
    }

    if (!digitsOnly.isValidPhone) {
      return context.currentLanguage(AppStrings.phoneInvalid);
    }

    if (!digitsOnly.isValidMobileOperatorCode) {
      return context.currentLanguage(AppStrings.phoneInvalidOperator);
    }

    return null;
  }

  static String? email(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required'; // TODO: Localize
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }
}