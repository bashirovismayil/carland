import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../local/language_local_service.dart';
import '../local/login_local_services.dart';

class MarkNotificationAsReadService {
  final _local = locator<LoginLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<void> markNotificationAsRead(int notificationId, bool setRead) async {
    final token = _local.accessToken;
    final currentLanguage = _languageService.currentLanguage;

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      'X-Client-Timezone': 'Asia/Baku',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = ApiConstants.markNotificationAsRead
        .replaceAll('{id}', notificationId.toString()) + setRead.toString();

    try {
      final resp = await authDio.post(
        url,
        options: Options(headers: headers),
      );

      if (resp.statusCode.isSuccess) {
        log('[MarkNotificationAsReadService] Success for notificationId: $notificationId, setRead: $setRead');
      } else {
        final message = _getErrorMessage(resp.statusCode ?? 0);
        throw Exception('Mark notification as read failed: $message');
      }
    } on DioException catch (e) {
      log('[MarkNotificationAsReadService] DioException: $e');
      if (e.response != null) {
        final message = _getErrorMessage(e.response?.statusCode ?? 0);
        throw Exception('Mark notification as read failed: $message');
      } else {
        throw Exception('Mark notification as read failed: Şəbəkə xətası');
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