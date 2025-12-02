import '../contractor/register_contractor.dart';
import '../models/remote/register_response.dart';
import '../services/remote/register_service.dart';

class RegisterRepository implements RegisterContractor {
  RegisterRepository(this._registerService);

  final RegisterService _registerService;

  @override
  Future<RegisterResponse> register({
    required String phoneNumber,
    required String name,
    required String surname,
  }) {
    return _registerService.register(
      phoneNumber: phoneNumber,
      name: name,
      surname: surname,
    );
  }
}