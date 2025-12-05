import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../models/remote/login_response.dart';

class LoginLocalService {
  LoginLocalService(this._box);

  final Box<String> _box;

  static const String _rememberMeKey = 'remember_me';

  Future<void> saveLoginResponse(LoginResponse resp) async {
    await _box.put('login', jsonEncode(resp.toJson()));
    await saveAccessToken(resp.accessToken);
    await saveRefreshToken(resp.refreshToken);
    await saveUserRole(resp.role);
  }

  LoginResponse? get loginResponse {
    final raw = _box.get('login');
    if (raw == null) return null;
    return LoginResponse.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // Token Operations
  Future<void> saveAccessToken(String token) async {
    if (token.isNotEmpty) await _box.put('accessToken', token);
  }

  String? get accessToken => _box.get('accessToken');

  Future<void> saveRefreshToken(String token) async {
    if (token.isNotEmpty) await _box.put('refreshToken', token);
  }

  String? get refreshToken => _box.get('refreshToken');

  // Role Operations
  Future<void> saveUserRole(UserRole role) async {
    await _box.put('userRole', role.value);
  }

  UserRole get currentUserRole {
    final roleStr = _box.get('userRole');
    if (roleStr == null) return UserRole.guest;
    return UserRole.fromString(roleStr);
  }

  // Authentication Status
  bool get isAuthenticated {
    final token = accessToken;
    return token != null && token.isNotEmpty;
  }

  bool get isGuest => currentUserRole.isGuest;

  // Guest Mode Operations
  bool get isGuestMode => _box.get('is_guest_mode') == 'true';

  Future<void> setGuestMode(bool isGuest) async =>
      await _box.put('is_guest_mode', isGuest.toString());

  Future<void> clearGuestMode() async => await _box.delete('is_guest_mode');

  Future<void> setRememberMe(bool value) async {
    await _box.put(_rememberMeKey, value.toString());
    print("💾 Remember Me durumu kaydedildi: $value");
  }

  bool get rememberMe {
    final value = _box.get(_rememberMeKey);
    return value == 'true';
  }

  Future<void> checkRememberMeOnStartup() async {
    print("🔍 App başlatıldı - Remember Me kontrolü yapılıyor...");

    if (!rememberMe) {
      print("🗑️ Remember Me KAPALI - Tüm bilgiler temizleniyor...");
      await clear();
    } else {
      print("✅ Remember Me AÇIK - Bilgiler korunuyor");
    }
  }

  bool get canViewAdminPanel => currentUserRole.canViewAdminPanel;

  bool get canViewUserFeatures => currentUserRole.canViewUserFeatures;

  bool get isSuperUser => currentUserRole.isSuperUser;

  // Navigation Helper
  String getHomeRoute() {
    final role = currentUserRole;
    switch (role) {
      case UserRole.guest:
        return '/guest';
      case UserRole.user:
        return '/user-home';
      case UserRole.admin:
        return '/admin-home';
      case UserRole.superAdmin:
        return '/super-admin-home';
      case UserRole.boss:
        return '/boss-home';
    }
  }

  Future<void> clear() async => await _box.clear();

  Future<void> logout() async {
    await clear();
    await setGuestMode(true);
  }
}