import 'package:flutter/services.dart';

class PhoneNumberFormatter {
  PhoneNumberFormatter._();

  static TextInputFormatter get phoneFormatter => _PhoneNumberInputFormatter();
}

class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length > 9) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

extension PhoneStringExtension on String {
  String get digitsOnly => replaceAll(RegExp(r'[^\d]'), '');

  String withCountryCode(String countryCode) {
    final digits = digitsOnly;
    final cleanCode = countryCode.replaceAll('+', '');
    return '+$cleanCode$digits';
  }
}