import 'package:dio/dio.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/setup_pass_response.dart';
import '../local/language_local_service.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../local/register_local_service.dart';

class SetupPassService {
  final _local = locator<RegisterLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<SetPassResponse> setPassword({
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final token = _local.registerToken;
    final currentLanguage = _languageService.currentLanguage;

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      'X-Skip-Token-Refresh': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = {
      'password': newPassword,
    };

    final resp = await authDio.put(
      ApiConstants.setPassword,
      data: body,
      options: Options(headers: headers),
    );

    if (resp.statusCode.isSuccess) {
      return SetPassResponse.fromJson(resp.data as Map<String, dynamic>);
    } else {
      throw Exception('SetPassword failed: ${resp.data}');
    }
  }
}