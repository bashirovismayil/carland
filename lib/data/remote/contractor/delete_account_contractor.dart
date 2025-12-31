import '../models/remote/delete_account_response.dart';

abstract class DeleteAccountContractor {
  Future<DeleteAccountResponse> deleteAccount();
}