import 'dart:developer';
import 'package:carland/cubit/auth/setup_pass/setup_pass_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/setup_pass_contractor.dart';
import '../../../data/remote/models/remote/setup_pass_response.dart';
import '../../../utils/di/locator.dart';

class SetupPassCubit extends Cubit<SetupPassState> {
  SetupPassCubit() : super(SetupPassInitial()) {
    _authRepo = locator<SetupPassContractor>();
  }

  late final SetupPassContractor _authRepo;

  Future<void> submit({
    required String password,
    required String confirmPassword,
  }) async {
    try {
      emit(SetupPassLoading());
      final SetPassResponse resp = await _authRepo.setPassword(
        newPassword: password,
        newPasswordConfirm: confirmPassword,
      );
      emit(SetupPassSuccess(resp.message));
    } catch (e) {
      emit(SetupPassError(e.toString()));
      log("Setup Pass Error: $e");
    }
  }
}
