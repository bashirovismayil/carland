import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService(this._pinBox);

  final Box _pinBox;
  final LocalAuthentication _auth = LocalAuthentication();

  static const String _biometricEnabledKey = 'biometric_enabled';

  // ── Getters ──

  bool get isEnabled {
    return _pinBox.get(_biometricEnabledKey, defaultValue: false) as bool? ?? false;
  }

  // ── Device Capability ──

  /// Cihazın biyometrik donanımı var mı? (Face ID sensörü, parmak izi okuyucu)
  Future<bool> isHardwareSupported() async {
    try {
      return await _auth.canCheckBiometrics;
    } on LocalAuthException catch (e) {
      debugPrint('[BiometricService] Hardware check failed: ${e.code}');
      return false;
    }
  }

  /// Kullanıcı biyometrik kaydetmiş mi? (Face ID kurmuş mu?)
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } on LocalAuthException catch (e) {
      debugPrint('[BiometricService] Enrolled check failed: ${e.code}');
      return false;
    }
  }

  /// Donanım destekli VE kullanıcı kayıt yapmış mı?
  Future<bool> isReadyToAuthenticate() async {
    final supported = await isHardwareSupported();
    if (!supported) return false;
    return hasEnrolledBiometrics();
  }

  // ── Preference ──

  Future<void> setEnabled(bool value) async {
    await _pinBox.put(_biometricEnabledKey, value);
  }

  Future<void> disable() async {
    await setEnabled(false);
  }

  // ── Authentication ──

  /// Biyometrik doğrulama başlat.
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );
    } on LocalAuthException catch (e) {
      debugPrint('[BiometricService] Auth failed: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] Unexpected error: $e');
      return false;
    }
  }

  /// Aktifleştirme öncesi test doğrulaması.
  /// Başarılı olursa preference'ı da kaydeder.
  Future<bool> enrollAndEnable({required String localizedReason}) async {
    final ready = await isReadyToAuthenticate();
    if (!ready) return false;

    final authenticated = await authenticate(localizedReason: localizedReason);
    if (authenticated) {
      await setEnabled(true);
    }
    return authenticated;
  }
}