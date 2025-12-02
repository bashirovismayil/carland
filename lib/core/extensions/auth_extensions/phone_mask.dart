extension PhoneMaskExtension on String {
  String get maskedPhone {
    if (length < 10) return '+XXXxxxxxxxxxx';
    return '+994 ** *** ${substring(length - 4, length - 2)} ${substring(length - 2)}';
  }
}
