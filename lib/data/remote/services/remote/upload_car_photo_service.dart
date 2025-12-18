import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/upload_car_photo_response.dart';
import '../local/language_local_service.dart';

class UploadCarPhotoService {
  final _languageService = locator<LanguageLocalService>();

  Future<UploadCarPhotoResponse> uploadCarPhoto({
    required String carId,
    required File imageFile,
  }) async {
    log('[UploadCarPhotoService] Uploading car photo for carId: $carId');
    final currentLanguage = _languageService.currentLanguage;

    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final Response resp = await authDio.post(
        '${ApiConstants.uploadCarPhoto}$carId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
            'Accept-Language': currentLanguage,
            'X-Client-Timezone': 'Asia/Baku',
          },
        ),
      );

      log('[UploadCarPhotoService] Upload Response Status: ${resp.statusCode}');
      log('[UploadCarPhotoService] Upload Response Data: ${resp.data}');

      if (resp.statusCode.isSuccess) {
        return UploadCarPhotoResponse.fromJson(
            resp.data as Map<String, dynamic>);
      } else {
        final message = _getErrorMessage(resp.statusCode ?? 0);
        throw Exception('Upload car photo failed: $message');
      }
    } on DioException catch (e) {
      log('[UploadCarPhotoService] Upload DioException: ${e.response?.statusCode}');

      if (e.response != null) {
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 400) {
          throw Exception('INVALID_FILE_FORMAT');
        } else if (statusCode == 401) {
          throw Exception('UNAUTHORIZED');
        } else if (statusCode == 406) {
          throw Exception('NOT_ACCEPTABLE');
        } else if (statusCode == 413) {
          throw Exception('FILE_TOO_LARGE');
        } else {
          final message = _getErrorMessage(statusCode);
          throw Exception('Upload car photo failed: $message');
        }
      } else {
        throw Exception('Upload car photo failed: Şəbəkə xətası');
      }
    } catch (e) {
      log('[UploadCarPhotoService] Upload Error: $e');
      rethrow;
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