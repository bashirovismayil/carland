import '../models/remote/user_add_details_response.dart';

abstract class UserAddDetailsContractor {
  Future<UserAddDetailsResponse> addUserDetails();
}