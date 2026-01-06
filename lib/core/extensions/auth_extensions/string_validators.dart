extension StringValidators on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidPhone => RegExp(r'^[0-9]{9}$').hasMatch(this);

  bool get isStrongPassword =>
      length >= 8 &&
          hasRegExp(RegExp(r'[A-Z]')) &&
          hasRegExp(RegExp(r'[0-9]')) &&
          hasRegExp(RegExp(r'[!@#\$&*~]'));

  bool get isAlphabetic =>
      RegExp(r'^[a-zA-ZığüşöçİĞÜŞÖÇəƏа-яА-ЯёЁ\s]+$').hasMatch(this);

  bool hasRegExp(RegExp exp) => exp.hasMatch(this);
}

extension ConfirmPasswordValidator on String {
  bool matches(String other) => this == other;
}

extension MobileOperatorValidator on String {
  bool get isValidMobileOperatorCode {
    if (length < 2) return false;
    final operatorPrefix = substring(0, 2);
    const validCodes = {'50', '51', '52', '53', '54', '10', '55', '99', '70', '77'};
    return validCodes.contains(operatorPrefix);
  }

  String? get operatorName {
    if (length < 2) return null;
    final prefix = substring(0, 2);
    switch (prefix) {
      case '50':
      case '51':
      case '52':
      case '53':
      case '54':
      case '10':
        return 'Azercell';
      case '55':
      case '99':
        return 'Bakcell';
      case '70':
      case '77':
        return 'Nar';
      default:
        return null;
    }
  }
}