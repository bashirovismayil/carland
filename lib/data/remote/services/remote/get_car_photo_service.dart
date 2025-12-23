import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../local/language_local_service.dart';
import '../local/login_local_services.dart';

class GetCarPhotoService {
  final _local = locator<LoginLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<Uint8List> getCarPhoto(int carId) async {
    log('[GetCarPhotoService] Getting car photo for carId: $carId');
    final token = _local.accessToken;
    final currentLanguage = _languageService.currentLanguage;

    try {
      final Response resp = await authDio.get(
        '${ApiConstants.getCarPhoto}$carId',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
            'Accept-Language': currentLanguage,
            'X-Client-Timezone': 'Asia/Baku',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (resp.statusCode.isSuccess) {
        log('[GetCarPhotoService] Success: Photo received');
        log('[GetCarPhotoService] Response Content-Type: ${resp.headers.value('content-type')}');
        log('[GetCarPhotoService] Response Data Length: ${resp.data.length}');
        return Uint8List.fromList(resp.data);
      } else {
        final message = _getErrorMessage(resp.statusCode ?? 0);
        throw Exception('Get car photo failed: $message');
      }
    } on DioException catch (e) {
      log('[GetCarPhotoService] DioException: $e');
      if (e.response != null) {
        final message = _getErrorMessage(e.response?.statusCode ?? 0);
        throw Exception('Get car photo failed: $message');
      } else {
        throw Exception('Get car photo failed: Şəbəkə xətası');
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
      case 406:
        return 'Not Acceptable - Server configuration issue';
      case 408:
        return AppTranslation.translate(AppStrings.requestTimeoutAlt);
      case 409:
        return AppTranslation.translate(AppStrings.conflictAlt);
      case 413:
        return AppTranslation.translate(AppStrings.fileSizeTooLarge);
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