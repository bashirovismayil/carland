import 'package:flutter/material.dart';
import 'package:carcat/core/extensions/auth_extensions/string_validators.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';

class PhoneValidator {
  const PhoneValidator._();

  static String? validate(String? value, BuildContext context) {
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
}

class PasswordValidator {
  const PasswordValidator._();

  static String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return context.currentLanguage(AppStrings.passwordRequired);
    }

    if (value.length < 6) {
      return context.currentLanguage(AppStrings.passwordTooShort);
    }

    return null;
  }
}