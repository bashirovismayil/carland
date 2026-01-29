import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinLocalService {
  PinLocalService(this._pinBox);

  final Box _pinBox;

  static const String _pinKey = 'user_pin_hash';
  static const String _pinEnabledKey = 'pin_enabled';

  bool _isSessionVerified = false;
  bool _bypassPinOnce = false;

  static const _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyStorageKey = 'hive_encryption_key';

  bool get hasPin {
    return _pinBox.get(_pinEnabledKey, defaultValue: false) as bool? ?? false;
  }

  bool get isSessionVerified => _isSessionVerified;

  bool get shouldAskPin => hasPin && !_isSessionVerified && !_bypassPinOnce;

  void setBypassPinOnce() {
    _bypassPinOnce = true;
  }

  void markSessionVerified() {
    _isSessionVerified = true;
    _bypassPinOnce = false;
  }

  void resetSession() {
    _isSessionVerified = false;
  }

  Future<void> setPin(String pin) async {
    final hashedPin = _hashPin(pin);
    await _pinBox.put(_pinKey, hashedPin);
    await _pinBox.put(_pinEnabledKey, true);
  }

  bool verifyPin(String pin) {
    if (!hasPin) return false;

    final storedHash = _pinBox.get(_pinKey) as String?;
    if (storedHash == null) return false;

    final inputHash = _hashPin(pin);
    return storedHash == inputHash;
  }

  Future<void> removePin() async {
    await _pinBox.delete(_pinKey);
    await _pinBox.delete(_pinEnabledKey);
    _isSessionVerified = false;
  }

  Future<void> clearPin() async {
    await removePin();
  }

  Future<bool> updatePin(String oldPin, String newPin) async {
    if (!verifyPin(oldPin)) {
      return false;
    }
    await setPin(newPin);
    return true;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool get isPinEnabled => hasPin;

  static Future<List<int>> getEncryptionKey() async {
    String? encryptionKeyString = await _secureStorage.read(
      key: _encryptionKeyStorageKey,
    );

    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _encryptionKeyStorageKey,
        value: base64UrlEncode(key),
      );
      return key;
    }

    return base64Url.decode(encryptionKeyString);
  }
}