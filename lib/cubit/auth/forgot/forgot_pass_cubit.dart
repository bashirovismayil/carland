import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/remote/contractor/forgot_pass_contractor.dart';
import '../../../../data/remote/services/local/register_local_service.dart';
import '../../../../utils/di/locator.dart';
import '../../../data/remote/models/remote/forgot_pass_response.dart';
import '../../../data/remote/models/remote/register_response.dart';
import 'forgot_pass_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial()) {
    _repo = locator<ForgotPasswordContractor>();
    _local = locator<RegisterLocalService>();
  }

  late final ForgotPasswordContractor _repo;
  late final RegisterLocalService _local;

  String _formatPhoneNumber(String phoneNumber) {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (!cleanedNumber.startsWith('994')) {
      cleanedNumber = '994$cleanedNumber';
    }
    return '+$cleanedNumber';
  }

  Future<void> submit({
    required String phoneNumber,
  }) async {
    try {
      emit(ForgotPasswordLoading());
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final ForgotPasswordResponse resp = await _repo.forgotPassword(
        phoneNumber: formattedPhone,
      );

      final registerResponse = RegisterResponse(
        registerToken: resp.registerToken,
        message: resp.message,
      );
      await _local.saveRegisterResponse(registerResponse);

      emit(ForgotPasswordSuccess(
        message: resp.message,
        registerToken: resp.registerToken,
      ));
    } catch (e) {
      emit(ForgotPasswordError("No account is registered with the number you entered"));
      log("Forgot Password Error: $e");
    }
  }
}