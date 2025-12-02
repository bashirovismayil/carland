import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/remote/register_response.dart';

class RegisterLocalService {
  RegisterLocalService(this._box);

  final Box<String> _box;

  Future<void> saveRegisterResponse(RegisterResponse response) async {
    _box.put('register', jsonEncode(response.toJson()));
  }

  RegisterResponse? get registerResponse {
    try {
      String? registerResponse = _box.get('register');
      if (registerResponse == null) return null;
      RegisterResponse decodedResponse = RegisterResponse.fromJson(
        jsonDecode(registerResponse) as Map<String, dynamic>,
      );
      return decodedResponse;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAccessToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      await _box.put('accessToken', token);
    }
  }

  String? get accessToken => _box.get('accessToken');

  Future<void> saveRefreshToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      await _box.put('refreshToken', token);
    }
  }

  String? get refreshToken => _box.get('refreshToken');

  Future<void> deleteSaveByKey(String key) async {
    await _box.delete(key);
  }

  String? get token => registerResponse?.registerToken;

  String? get message => registerResponse?.message;

  Future<void> savePhoneNumber(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      await _box.put('registeredPhone', phoneNumber);
    }
  }

  String? get registeredPhoneNumber => _box.get('registeredPhone');
}
