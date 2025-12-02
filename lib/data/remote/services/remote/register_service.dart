import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/dio/public_dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/register_response.dart';
import '../local/language_local_service.dart';
import '../local/register_local_service.dart';
import '../../../../core/extensions/status/status_code_extension.dart';

class RegisterService {
  final token = locator<RegisterLocalService>().token;
  final languageService = locator<LanguageLocalService>();

  Future<RegisterResponse> register({
    required String name,
    required String surname,
    required String phoneNumber,
  }) async {
    final endpoint = ApiConstants.register;
    final nm = name.trim();
    final sn = surname.trim();
    final pn = phoneNumber.trim();

    final requestBody = {
      "name": nm,
      "surname": sn,
      "phoneNumber": pn,
    };

    final currentLanguage = languageService.currentLanguage;

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      //'X-Client-Timezone': 'Asia/Baku',
    };
    final token = locator<RegisterLocalService>().token;
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    log('Register Request Body: $requestBody');
    log('Register Headers: $headers');

    final response = await authDio.post(
      endpoint,
      data: requestBody,
      options: Options(headers: headers),
    );

    if (response.statusCode.isSuccess) {
      return RegisterResponse.fromJson(response.data);
    } else {
      throw Exception("Error: ${response.data}");
    }
  }
}
