import 'package:flutter/services.dart';

class CapitalCaseFormatter extends TextInputFormatter {
  static const allowedSpecialChars = {
    '-',
    '/',
    '&',
    "'",
  };

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;
    final filteredText = _filterText(text);
    final formattedText = _capitalizeWords(filteredText);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formattedText.length),
      ),
    );
  }

  String _filterText(String text) {
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charCode = char.codeUnitAt(0);
      final isEnglishLetter = (charCode >= 65 && charCode <= 90) ||
          (charCode >= 97 && charCode <= 122);
      final isDigit = charCode >= 48 && charCode <= 57;
      final isSpace = charCode == 32;
      final isAllowedSpecialChar = allowedSpecialChars.contains(char);

      if (isEnglishLetter || isDigit || isSpace || isAllowedSpecialChar) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;

    final words = text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      int startIndex = 0;
      while (startIndex < word.length &&
          allowedSpecialChars.contains(word[startIndex])) {
        startIndex++;
      }
      if (startIndex >= word.length) return word;
      return word.substring(0, startIndex) +
          word[startIndex].toUpperCase() +
          word.substring(startIndex + 1).toLowerCase();
    }).toList();

    return capitalizedWords.join(' ');
  }
}