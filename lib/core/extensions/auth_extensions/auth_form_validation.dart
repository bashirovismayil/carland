extension StringValidators on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidPhone =>
      RegExp(r'^[0-9]{9}$').hasMatch(this);

  bool get isStrongPassword =>
      length >= 8 &&
          hasRegExp(RegExp(r'[A-Z]')) &&
          hasRegExp(RegExp(r'[0-9]')) &&
          hasRegExp(RegExp(r'[!@#\$&*~]'));

  bool get isAlphabetic =>
      RegExp(r'^[a-zA-ZığüşöçİĞÜŞÖÇəƏ\s]+$').hasMatch(this);
}

extension RegExpExtension on String {
  bool hasRegExp(RegExp exp) => exp.hasMatch(this);
}

extension ConfirmPasswordValidator on String {
  bool matches(String other) => this == other;
}