import '../models/remote/register_response.dart';

abstract class RegisterContractor {
  Future<RegisterResponse> register({
    required String phoneNumber,
    required String name,
    required String surname,

  });
}
