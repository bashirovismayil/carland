import 'package:dio/dio.dart';
import '../../../../core/dio/auth_dio.dart';
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
        return 'Yanlış sorğu göndərildi';
      case 401:
        return 'İcazəniz yoxdur. Yenidən giriş edin';
      case 403:
        return 'Bu əməliyyatı yerinə yetirmək üçün səlahiyyətiniz yoxdur';
      case 404:
        return 'Məlumat tapılmadı';
      case 408:
        return 'Sorğu vaxtı doldu. Yenidən cəhd edin';
      case 409:
        return 'Konflikt baş verdi';
      case 415:
        return 'Dəstəklənməyən məzmun növü';
      case 429:
        return 'Çox sayda sorğu göndərildi. Bir az gözləyin';
      case 500:
        return 'Server xətası baş verdi';
      case 501:
        return 'Server tərəfindən yerinə yetirilməyib';
      case 502:
        return 'Server əlaqə xətası';
      case 503:
        return 'Xidmət müvəqqəti əlçatan deyil';
      case 504:
        return 'Server cavab vermə vaxtı doldu';
      case 505:
        return 'HTTP versiyası dəstəklənmir';
      default:
        return 'Xəta baş verdi (Kod: $statusCode)';
    }
  }
}
