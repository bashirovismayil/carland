import 'package:dio/dio.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/otp_send_response.dart';
import '../../models/remote/otp_verify_response.dart';
import '../local/language_local_service.dart';
import '../local/register_local_service.dart';
import '../../../../core/extensions/status/status_code_extension.dart';



class OtpService {
  final _local = locator<RegisterLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<OtpSendResponse> createAndSend({ required String phoneNumber }) async {
    final token = _local.registerToken;
    final currentLanguage = _languageService.currentLanguage;

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      'X-Client-Timezone': 'Asia/Baku',
      'X-Skip-Token-Refresh': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await authDio.post(
      ApiConstants.otpCreateSend,
      data: { 'phoneNumber': phoneNumber },
      options: Options(headers: headers),
    );

    if (resp.statusCode.isSuccess) {
      return OtpSendResponse.fromJson(resp.data);
    } else {
      throw Exception('OTP send error: ${resp.data}');
    }
  }

  Future<OtpVerifyResponse> verify({required String otpCode}) async {
    final token = _local.registerToken;
    final currentLanguage = _languageService.currentLanguage;

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      'X-Client-Timezone': 'Asia/Baku',
      'X-Skip-Token-Refresh': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await authDio.post(
      ApiConstants.otpVerify,
      data: {'otpCode': otpCode},
      options: Options(headers: headers),
    );

    if (resp.statusCode.isSuccess) {
      return OtpVerifyResponse.fromJson(resp.data);
    } else {
      throw Exception('OTP verify error: ${resp.data}');
    }
  }
}