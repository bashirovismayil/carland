import '../../../data/remote/models/remote/delete_account_response.dart';

sealed class DeleteAccountState {}

final class DeleteAccountInitial extends DeleteAccountState {}

final class DeleteAccountLoading extends DeleteAccountState {}

final class DeleteAccountSuccess extends DeleteAccountState {
  final DeleteAccountResponse response;
  DeleteAccountSuccess(this.response);
}

final class DeleteAccountError extends DeleteAccountState {
  final String message;
  DeleteAccountError(this.message);
}