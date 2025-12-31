import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/delete_account_contractor.dart';
import '../../../data/remote/models/remote/delete_account_response.dart';
import '../../../utils/di/locator.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit() : super(DeleteAccountInitial()) {
    _deleteRepo = locator<DeleteAccountContractor>();
  }

  late final DeleteAccountContractor _deleteRepo;

  Future<void> deleteAccount() async {
    try {
      emit(DeleteAccountLoading());

      final DeleteAccountResponse response = await _deleteRepo.deleteAccount();

      log("Delete Account Success: ${response.toJson()}");
      emit(DeleteAccountSuccess(response));
    } catch (e) {
      emit(DeleteAccountError(e.toString()));
      log("Delete Account Error: $e");
    }
  }
}