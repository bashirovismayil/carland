import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/user_add_details_response.dart';
import '../local/language_local_service.dart';
import '../local/login_local_services.dart';

class UserAddDetailsService {
  final _local = locator<LoginLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<UserAddDetailsResponse> addUserDetails() async {
    final token = _local.accessToken;
    final currentLanguage = _languageService.currentLanguage;

    log('[UserAddDetailsService] 🚀 Starting request...');

    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      'X-Client-Timezone': 'Asia/Baku',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final registerEndpoint = ApiConstants.register;
    if (registerEndpoint.contains('role=user')) {
      headers['inviterId'] = '0';
      log('[UserAddDetailsService] ✅ Added inviterId: 0 (role=user detected)');
    }

    log('[UserAddDetailsService] 📋 Headers: $headers');

    try {
      final resp = await authDio.post(
        ApiConstants.userAddDetails,
        options: Options(headers: headers),
      );

      log('[UserAddDetailsService] 📥 Response received');
      log('[UserAddDetailsService] 📊 Status Code: ${resp.statusCode}');
      log('[UserAddDetailsService] 📦 Response Data: ${resp.data}');

      if (resp.statusCode.isSuccess) {
        log('[UserAddDetailsService] ✅ Success');
        return UserAddDetailsResponse.fromJson(
          resp.data is Map<String, dynamic>
              ? resp.data as Map<String, dynamic>
              : {'message': 'Details added successfully'},
        );
      } else {
        final message = _getErrorMessage(resp.statusCode ?? 0);
        throw Exception('Add user details failed: $message');
      }
    } on DioException catch (e) {
      log('[UserAddDetailsService] ❌ DioException: $e');
      log('[UserAddDetailsService] ❌ Response: ${e.response?.data}');

      if (e.response != null) {
        final message = _getErrorMessage(e.response?.statusCode ?? 0);
        throw Exception('Add user details failed: $message');
      } else {
        throw Exception('Add user details failed: Şəbəkə xətası');
      }
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return AppTranslation.translate(AppStrings.badRequestAlt);
      case 401:
        return AppTranslation.translate(AppStrings.unauthorizedAlt);
      case 403:
        return AppTranslation.translate(AppStrings.forbiddenAlt);
      case 404:
        return AppTranslation.translate(AppStrings.notFoundAlt);
      case 408:
        return AppTranslation.translate(AppStrings.requestTimeoutAlt);
      case 409:
        return AppTranslation.translate(AppStrings.conflictAlt);
      case 415:
        return AppTranslation.translate(AppStrings.unsupportedMediaTypeAlt);
      case 429:
        return AppTranslation.translate(AppStrings.tooManyRequestsAlt);
      case 500:
        return AppTranslation.translate(AppStrings.internalServerErrorAlt);
      case 501:
        return AppTranslation.translate(AppStrings.notImplementedAlt);
      case 502:
        return AppTranslation.translate(AppStrings.badGatewayAlt);
      case 503:
        return AppTranslation.translate(AppStrings.serviceUnavailableAlt);
      case 504:
        return AppTranslation.translate(AppStrings.gatewayTimeoutAlt);
      case 505:
        return AppTranslation.translate(AppStrings.httpVersionNotSupportedAlt);
      default:
        return AppTranslation.translate(AppStrings.errorOccurred);
    }
  }
}