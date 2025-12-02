class CountryCode {
  final String code;
  final String name;
  final String flag;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
  });
}

extension CountryCodeValidator on String {
  static const List<CountryCode> countryCodes = [
    CountryCode(code: '+994', name: 'Azərbaycan', flag: '🇦🇿'),
  ];

  bool get isValidCountryCode {
    return countryCodes.any((country) => country.code == this);
  }

  static CountryCode get defaultCountryCode => countryCodes.first;

  static CountryCode? getCountryByCode(String code) {
    try {
      return countryCodes.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }
}