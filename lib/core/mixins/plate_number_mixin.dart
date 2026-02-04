import 'package:flutter/services.dart';

mixin PlateNumberFormatterMixin {
  TextInputFormatter get formatter;

  String get pattern;

  String get hint;
}

class AzerbaijanPlateNumberFormatter extends TextInputFormatter
    with PlateNumberFormatterMixin {
  @override
  String get pattern => '##-AA-###';

  @override
  String get hint => '77-AA-509';

  @override
  TextInputFormatter get formatter => this;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsAndLetters =
        newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    digitsAndLetters = digitsAndLetters.toUpperCase();

    StringBuffer formatted = StringBuffer();
    int charIndex = 0;

    while (charIndex < digitsAndLetters.length && formatted.length < 2) {
      final char = digitsAndLetters[charIndex];
      if (_isDigit(char)) {
        formatted.write(char);
      }
      charIndex++;
    }

    if (formatted.length == 2 && charIndex < digitsAndLetters.length) {
      formatted.write('-');
    }

    int letterCount = 0;
    while (charIndex < digitsAndLetters.length && letterCount < 2) {
      final char = digitsAndLetters[charIndex];
      if (_isLetter(char)) {
        formatted.write(char);
        letterCount++;
      }
      charIndex++;
    }

    if (letterCount == 2 && charIndex < digitsAndLetters.length) {
      formatted.write('-');
    }

    int lastDigitCount = 0;
    while (charIndex < digitsAndLetters.length && lastDigitCount < 3) {
      final char = digitsAndLetters[charIndex];
      if (_isDigit(char)) {
        formatted.write(char);
        lastDigitCount++;
      }
      charIndex++;
    }

    final formattedText = formatted.toString();

    int newCursorPosition = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  bool _isDigit(String char) => RegExp(r'[0-9]').hasMatch(char);

  bool _isLetter(String char) => RegExp(r'[A-Za-z]').hasMatch(char);

  static bool isValid(String plateNumber) {
    final regex = RegExp(r'^\d{2}-[A-Z]{2}-\d{3}$');
    return regex.hasMatch(plateNumber);
  }

  static int get maxLength => 10; // ##-AA-###
}

class TurkeyPlateNumberFormatter extends TextInputFormatter
    with PlateNumberFormatterMixin {
  @override
  String get pattern => '## AAA ##';

  @override
  String get hint => '34 ABC 123';

  @override
  TextInputFormatter get formatter => this;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsAndLetters =
        newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    digitsAndLetters = digitsAndLetters.toUpperCase();

    StringBuffer formatted = StringBuffer();
    int charIndex = 0;

    while (charIndex < digitsAndLetters.length && formatted.length < 2) {
      final char = digitsAndLetters[charIndex];
      if (_isDigit(char)) {
        formatted.write(char);
      }
      charIndex++;
    }

    if (formatted.length == 2 && charIndex < digitsAndLetters.length) {
      formatted.write(' ');
    }

    int letterCount = 0;
    while (charIndex < digitsAndLetters.length && letterCount < 3) {
      final char = digitsAndLetters[charIndex];
      if (_isLetter(char)) {
        formatted.write(char);
        letterCount++;
      }
      charIndex++;
    }

    if (letterCount > 0 && charIndex < digitsAndLetters.length) {
      formatted.write(' ');
    }

    int lastDigitCount = 0;
    while (charIndex < digitsAndLetters.length && lastDigitCount < 4) {
      final char = digitsAndLetters[charIndex];
      if (_isDigit(char)) {
        formatted.write(char);
        lastDigitCount++;
      }
      charIndex++;
    }

    final formattedText = formatted.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  bool _isDigit(String char) => RegExp(r'[0-9]').hasMatch(char);

  bool _isLetter(String char) => RegExp(r'[A-Za-z]').hasMatch(char);

  static bool isValid(String plateNumber) {
    final regex = RegExp(r'^\d{2}\s[A-Z]{1,3}\s\d{2,4}$');
    return regex.hasMatch(plateNumber);
  }

  static int get maxLength => 12;
}
