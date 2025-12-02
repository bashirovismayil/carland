import '../contractor/login_contractor.dart';
import '../models/remote/login_response.dart';
import '../services/remote/login_service.dart';

class LoginRepository implements LoginContractor {
  final LoginService _service;

  LoginRepository(this._service);

  @override
  Future<LoginResponse> login({
    required String phoneNumber,
    required String password,
  }) => _service.login(phoneNumber: phoneNumber, password: password);
}
