import '../contractor/user_add_details_contractor.dart';
import '../models/remote/user_add_details_response.dart';
import '../services/remote/user_add_details_service.dart';

class UserAddDetailsRepository implements UserAddDetailsContractor {
  UserAddDetailsRepository(this._service);

  final UserAddDetailsService _service;

  @override
  Future<UserAddDetailsResponse> addUserDetails() {
    return _service.addUserDetails();
  }
}