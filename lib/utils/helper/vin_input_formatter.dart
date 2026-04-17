import 'package:flutter/services.dart';

class VinInputFormatter extends TextInputFormatter {
  static final RegExp _validChars = RegExp(r'[A-HJ-NPR-Z0-9]');
  final VoidCallback? onInvalidCharacter;
  VinInputFormatter({this.onInvalidCharacter});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String upperText = newValue.text.toUpperCase();
    final String filtered = upperText
        .split('')
        .where((char) => _validChars.hasMatch(char))
        .join();
    if (filtered.length < upperText.length &&
        newValue.text.length > oldValue.text.length) {
      onInvalidCharacter?.call();
    }

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(
        offset: filtered.length,
      ),
    );
  }

  static bool isValid(String vin) {
    if (vin.length != 17) return false;
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin);
  }
}