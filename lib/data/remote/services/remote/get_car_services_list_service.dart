// lib/data/remote/services/remote/get_car_services_service.dart

import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/get_car_services_response.dart';
import '../local/language_local_service.dart';
import '../local/login_local_services.dart';

class GetCarServicesService {
  final _local = locator<LoginLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<GetCarServicesResponse> getCarServices(int carId) async {
    final token = _local.accessToken;
    final currentLanguage = _languageService.currentLanguage;

    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLanguage,
      'X-Client-Timezone': 'Asia/Baku',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final resp = await authDio.get(
        '${ApiConstants.getCarServices}$carId',
        options: Options(headers: headers),
      );

      if (resp.statusCode.isSuccess) {
        log('[GetCarServicesService] Success for carId: $carId');

        return GetCarServicesResponse.fromJson(resp.data as Map<String, dynamic>);
      } else {
        final message = _getErrorMessage(resp.statusCode ?? 0);
        throw Exception('Get car services failed: $message');
      }
    } on DioException catch (e) {
      log('[GetCarServicesService] DioException: $e');
      if (e.response != null) {
        final message = _getErrorMessage(e.response?.statusCode ?? 0);
        throw Exception('Get car services failed: $message');
      } else {
        throw Exception('Get car services failed: Şəbəkə xətası');
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