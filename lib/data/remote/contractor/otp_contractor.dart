import '../models/remote/otp_send_response.dart';
import '../models/remote/otp_verify_response.dart';

abstract class OtpContractor {
  Future<OtpSendResponse> createAndSend({ required String phoneNumber });
  Future<OtpVerifyResponse> verify({ required String otpCode });
}