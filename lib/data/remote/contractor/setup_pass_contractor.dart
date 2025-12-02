import '../models/remote/setup_pass_response.dart';

abstract class SetupPassContractor {
  Future<SetPassResponse> setPassword({
    required String newPassword,
    required String newPasswordConfirm,
  });
}
