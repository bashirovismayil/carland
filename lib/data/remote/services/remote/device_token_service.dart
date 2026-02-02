import 'package:dio/dio.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/device_token_response.dart';
import '../local/language_local_service.dart';
import '../local/login_local_services.dart';
import '../local/user_local_service.dart';
import '../../../../core/extensions/status/status_code_extension.dart';


class DeviceTokenService {
  final _userLocal = locator<UserLocalService>();
  final _local = locator<LoginLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<DeviceTokenResponse> sendDeviceToken({
    required String deviceToken,
    required String platform,
  }) async {
    final userId = _userLocal.userId;
    final token = _local.accessToken;
    final currentLanguage = _languageService.currentLanguage;

    if (userId == null) {
      throw Exception('User ID tapılmadı');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = {
      'userId': userId,
      'deviceToken': deviceToken,
      'platform': platform,
    };

    try {
      final resp = await authDio.post(
        ApiConstants.deviceToken,
        data: body,
        options: Options(headers: headers),
      );

      if (resp.statusCode.isSuccess) {
        return DeviceTokenResponse.fromJson(resp.data as Map<String, dynamic>);
      } else {
        final message = _getErrorMessage(resp.statusCode ?? 0);
        throw Exception('Device token registration failed: $message');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = _getErrorMessage(e.response?.statusCode ?? 0);
        throw Exception('Device token registration failed: $message');
      } else {
        throw Exception('Device token registration failed: Şəbəkə xətası');
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
