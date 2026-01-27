import 'package:dio/dio.dart';
import '../../../../../core/dio/auth_dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/forgot_pass_response.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../local/language_local_service.dart';

class ForgotPasswordService {
  final _languageService = locator<LanguageLocalService>();

  Future<ForgotPasswordResponse> forgotPassword({
    required String phoneNumber,
  }) async {
    final currentLanguage = _languageService.currentLanguage;
    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      'X-Skip-Token-Refresh': 'true',
    };

    final body = {
      'phoneNumber': phoneNumber,
    };

    final resp = await authDio.put(
      ApiConstants.forgotPassword,
      data: body,
      options: Options(headers: headers),
    );

    if (resp.statusCode.isSuccess) {
      return ForgotPasswordResponse.fromJson(resp.data as Map<String, dynamic>);
    } else {
      throw Exception('ForgotPassword failed: ${resp.data}');
    }
  }
}