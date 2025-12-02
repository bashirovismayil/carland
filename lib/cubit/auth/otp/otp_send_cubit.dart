import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/otp_contractor.dart';
import '../../../utils/di/locator.dart';
part 'otp_send_state.dart';

class OtpSendCubit extends Cubit<OtpSendState> {
  OtpSendCubit() : super(OtpSendInitial()) {
    _otpContractor = locator<OtpContractor>();
  }

  late final OtpContractor _otpContractor;

  Future<void> sendOtp(String rawPhone) async {
    emit(OtpSending());
    try {
      final formatted = '+994${rawPhone.replaceAll(RegExp(r'\s+'), '')}';
      final resp = await _otpContractor.createAndSend(phoneNumber: formatted);
      emit(OtpSendSuccess(resp.message));
    } catch (e) {
      emit(OtpSendError(e.toString()));
    }
  }
}
