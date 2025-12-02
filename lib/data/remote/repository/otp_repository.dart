import '../contractor/otp_contractor.dart';
import '../models/remote/otp_send_response.dart';
import '../models/remote/otp_verify_response.dart';
import '../services/remote/otp_service.dart';

class OtpRepository implements OtpContractor {
  OtpRepository(this._service);
  final OtpService _service;

  @override
  Future<OtpSendResponse> createAndSend({required String phoneNumber}) {
    return _service.createAndSend(phoneNumber: phoneNumber);
  }
  @override
  Future<OtpVerifyResponse> verify({required String otpCode}) =>
      _service.verify(otpCode: otpCode);
}
