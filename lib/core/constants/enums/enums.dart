import 'dart:ui';

enum LoginStatus { initial, submitting, success, error, guestMode }

enum SelectionMode { guest, login }

enum ImageType { asset, svg, lottie }

enum AuthFieldType { text, date, phone, password }

enum OtpVerifyType {
  registration,
  passwordReset,
  phoneVerification,
  test,
}

enum TitleType {
  login,
  signUp,
  otp,
  setupPassword,
  resetPassword,
  forgotPassword
}

enum SetupPassType {
  registration,
  resetPassword,
}

enum HospitalType { private, state }

enum ErrorType {
  network,
  server,
  validation,
  unauthorized,
  notFound,
  timeout,
  unknown,
}

enum UserRole {
  guest('GUEST'),
  user('USER'),
  admin('ADMIN'),
  superAdmin('SUPER_ADMIN'),
  boss('BOSS');

  const UserRole(this.value);

  final String value;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'GUEST':
      case 'GUESS':
        return UserRole.guest;
      case 'USER':
        return UserRole.user;
      case 'ADMIN':
        return UserRole.admin;
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'BOSS':
        return UserRole.boss;
      default:
        return UserRole.guest;
    }
  }

  bool get canViewAdminPanel =>
      this == UserRole.admin ||
          this == UserRole.superAdmin ||
          this == UserRole.boss;


  bool get canViewUserFeatures => this != UserRole.guest;

  bool get isSuperUser => this == UserRole.superAdmin || this == UserRole.boss;

  bool get isGuest => this == UserRole.guest;

  String get displayName {
    switch (this) {
      case UserRole.guest:
        return 'Qonaq';
      case UserRole.user:
        return 'İstifadəçi';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.boss:
        return 'Boss';
    }
  }
}
enum AppLanguage {
  azerbaijani('az', 'Azərbaycan dili', Locale('az', 'AZ')),
  english('en', 'English', Locale('en', 'US')),
  russian('ru', 'Русский', Locale('ru', 'RU'));

  final String code;
  final String displayName;
  final Locale locale;

  const AppLanguage(this.code, this.displayName, this.locale);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
          (lang) => lang.code == code,
      orElse: () => AppLanguage.azerbaijani,
    );
  }

  static AppLanguage fromLocale(Locale locale) {
    return AppLanguage.values.firstWhere(
          (lang) => lang.locale.languageCode == locale.languageCode,
      orElse: () => AppLanguage.azerbaijani,
    );
  }
}

enum CountryCode {
  azerbaijan('+994', '🇦🇿', 'Azərbaycan'),
  turkey('+90', '🇹🇷', 'Türkiyə'),
  russia('+7', '🇷🇺', 'Rusiya'),
  georgia('+995', '🇬🇪', 'Gürcüstan'),
  kazakhstan('+7', '🇰🇿', 'Qazaxıstan');

  const CountryCode(this.code, this.flag, this.displayName);

  final String code;
  final String flag;
  final String displayName;

  String get dialCode => code.replaceAll('+', '');

  static CountryCode get defaultCode => CountryCode.azerbaijan;

  static CountryCode? fromDialCode(String dialCode) {
    final cleaned = dialCode.replaceAll('+', '');
    try {
      return CountryCode.values.firstWhere(
            (c) => c.dialCode == cleaned,
      );
    } catch (_) {
      return null;
    }
  }
}
