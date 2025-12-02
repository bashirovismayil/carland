import '../models/remote/login_response.dart';

abstract class LoginContractor {
  Future<LoginResponse> login({
    required String phoneNumber,
    required String password,
  });
}
