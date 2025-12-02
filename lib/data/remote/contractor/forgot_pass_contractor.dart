import '../models/remote/forgot_pass_response.dart';

abstract class ForgotPasswordContractor {
  Future<ForgotPasswordResponse> forgotPassword({
    required String phoneNumber,
  });
}