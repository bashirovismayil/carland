import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/otp_contractor.dart';
import '../../../utils/di/locator.dart';
part 'otp_verify_state.dart';

class OtpVerifyCubit extends Cubit<OtpVerifyState> {
  OtpVerifyCubit() : super(OtpVerifyInitial()) {
    _otpContractor = locator<OtpContractor>();
  }

  late final OtpContractor _otpContractor;
  String otpCode = '';

  Future<void> verifyOtp() async {
    emit(OtpVerifying());
    try {
      final resp = await _otpContractor.verify(otpCode: otpCode);
      emit(OtpVerifySuccess(resp.message));
    } catch (e) {
      emit(OtpVerifyError(e.toString()));
    }
  }
}
