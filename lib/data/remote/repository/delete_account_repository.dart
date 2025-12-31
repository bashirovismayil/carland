import '../contractor/delete_account_contractor.dart';
import '../models/remote/delete_account_response.dart';
import '../services/remote/delete_account_service.dart';

class DeleteAccountRepository implements DeleteAccountContractor {
  DeleteAccountRepository(this._service);

  final DeleteAccountService _service;

  @override
  Future<DeleteAccountResponse> deleteAccount() {
    return _service.deleteAccount();
  }
}