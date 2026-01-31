import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/extensions/status/status_code_extension.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/send_feedback_response.dart';
import '../local/language_local_service.dart';
import '../local/login_local_services.dart';

class FeedbackService {
  final _local = locator<LoginLocalService>();
  final _languageService = locator<LanguageLocalService>();

  Future<List<String>> getFeedbackTypes() async {
    final response = await authDio.get(ApiConstants.getFeedbackTypes);
    return (response.data as List).map((e) => e as String).toList();
  }

  Future<SendFeedbackResponse> sendFeedback({
    required String type,
    required String subject,
    required String description,
    int? rating,
    String? filePath,
  }) async {
    final token = _local.accessToken;
    final currentLanguage = _languageService.currentLanguage;

    final headers = {
      'Accept-Language': currentLanguage,
      'X-Client-Timezone': 'Asia/Baku',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> jsonData = {
      "type": type,
      "subject": subject,
      "description": description,
      if (rating != null) "rating": rating,
    };

    FormData formData = FormData.fromMap({
      "data": MultipartFile.fromString(
        jsonEncode(jsonData),
        contentType: MediaType.parse('application/json'),
      ),
    });

    if (filePath != null && filePath.isNotEmpty) {
      formData.files.add(MapEntry(
        "file",
        await MultipartFile.fromFile(filePath),
      ));
    }

    try {
      final resp = await authDio.post(
        ApiConstants.sendFeedback,
        data: formData,
        options: Options(headers: headers),
      );

      if (resp.statusCode.isSuccess) {
        return SendFeedbackResponse.fromJson(resp.data as Map<String, dynamic>);
      } else {
        final message = _getErrorMessage(resp.statusCode ?? 0);
        throw Exception('Send feedback failed: $message');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = _getErrorMessage(e.response?.statusCode ?? 0);
        throw Exception('Send feedback failed: $message');
      } else {
        throw Exception('Send feedback failed: Şəbəkə xətası');
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