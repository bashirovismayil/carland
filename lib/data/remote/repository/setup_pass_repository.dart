import '../contractor/setup_pass_contractor.dart';
import '../models/remote/setup_pass_response.dart';
import '../services/remote/setup_pass_service.dart';

class SetupPassRepository implements SetupPassContractor {
  SetupPassRepository(this._service);

  final SetupPassService _service;

  @override
  Future<SetPassResponse> setPassword({
    required String newPassword,
    required String newPasswordConfirm,
  }) {
    return _service.setPassword(
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }
}
