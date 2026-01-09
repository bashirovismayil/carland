import 'package:flutter/services.dart';

class VinInputFormatter extends TextInputFormatter {
  static final RegExp _validChars = RegExp(r'[A-HJ-NPR-Z0-9]');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String filtered = newValue.text
        .toUpperCase()
        .split('')
        .where((char) => _validChars.hasMatch(char))
        .join();

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(
        offset: filtered.length.clamp(0, filtered.length),
      ),
    );
  }

  static bool isValid(String vin) {
    if (vin.length != 17) return false;
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin);
  }
}