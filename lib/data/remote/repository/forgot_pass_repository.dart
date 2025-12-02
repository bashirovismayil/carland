import '../contractor/forgot_pass_contractor.dart';
import '../models/remote/forgot_pass_response.dart';
import '../services/remote/forgot_pass_service.dart';

class ForgotPasswordRepository implements ForgotPasswordContractor {
  ForgotPasswordRepository(this._service);

  final ForgotPasswordService _service;

  @override
  Future<ForgotPasswordResponse> forgotPassword({
    required String phoneNumber,
  }) {
    return _service.forgotPassword(phoneNumber: phoneNumber);
  }
}