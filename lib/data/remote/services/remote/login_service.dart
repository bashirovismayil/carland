import 'package:dio/dio.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../utils/di/locator.dart';
import '../../../../utils/helper/app_exceptions.dart';
import '../../models/remote/login_response.dart';
import '../local/language_local_service.dart';

class LoginService {
  final Dio _dio;
  final _languageService = locator<LanguageLocalService>();

  LoginService(this._dio);

  Future<LoginResponse> login({
    required String phoneNumber,
    required String password,
  }) async {
    final endpoint = ApiConstants.login;
    final currentLanguage = _languageService.currentLanguage;
    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'phoneNumber': phoneNumber.trim(),
          'password': password.trim(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept-Language': currentLanguage,
          },
        ),
      );

      if (response.statusCode == null) {
        throw AppException.server(
          AppTranslation.translate(AppStrings.unknownInternalError),
        );
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          return LoginResponse.fromJson(response.data as Map<String, dynamic>);

        case 400:
          throw AppException.validation(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.badRequest),
            statusCode: 400,
          );

        case 401:
          throw AppException(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.invalidCredentials),
            type: ErrorType.unauthorized,
            statusCode: 401,
          );

        case 403:
          throw AppException(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.forbidden),
            type: ErrorType.unauthorized,
            statusCode: 403,
          );

        case 404:
          throw AppException.notFound(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.userNotFound),
          );

        case 422:
          throw AppException.validation(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.invalidData),
            statusCode: 422,
          );

        case 500:
          throw AppException.server(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.serverError),
            statusCode: 500,
          );

        case 502:
          throw AppException.server(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.serviceUnavailable),
            statusCode: 502,
          );

        case 503:
          throw AppException.server(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.serviceDown),
            statusCode: 503,
          );

        case 504:
          throw AppException.timeout(
            statusCode: 504,
          );

        default:
          throw AppException.server(
            _extractErrorMessage(response.data) ??
                AppTranslation.translate(AppStrings.loginFailed),
            statusCode: response.statusCode,
          );
      }
    } on DioException catch (e, s) {
      _logDioError(e, s);

      if (e.response != null) {
        final message = _extractErrorMessage(e.response!.data);
        if (message != null) {
          throw _createExceptionFromDioError(e, message);
        }
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw AppException.timeout();

        case DioExceptionType.badResponse:
          throw AppException.server(
            AppTranslation.translate(AppStrings.serverError),
          );

        case DioExceptionType.cancel:
          throw AppException(
            AppTranslation.translate(AppStrings.requestCancelled),
            type: ErrorType.unknown,
          );

        case DioExceptionType.connectionError:
          throw AppException.network(
            AppTranslation.translate(AppStrings.noInternet),
          );

        case DioExceptionType.badCertificate:
          throw AppException.network(
            AppTranslation.translate(AppStrings.badCertificate),
          );

        case DioExceptionType.unknown:
          if (e.message?.contains('SocketException') == true ||
              e.message?.contains('Failed host lookup') == true ||
              e.message?.contains('NetworkException') == true) {
            throw AppException.network(
              AppTranslation.translate(AppStrings.noInternet),
            );
          }
          throw AppException.network(
            AppTranslation.translate(AppStrings.networkError),
          );
      }
    } on AppException {
      rethrow;
    } catch (e, s) {
      _logGenericError(e, s);
      throw AppException.unknown(e);
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map<String, dynamic>) {
        if (data['message'] != null && data['message'] is String) {
          return data['message'] as String;
        }
        if (data['error'] != null && data['error'] is String) {
          return data['error'] as String;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  AppException _createExceptionFromDioError(DioException e, String message) {
    final statusCode = e.response?.statusCode;

    if (statusCode == null) {
      return AppException.network(message);
    }

    if (statusCode >= 500) {
      return AppException.server(message, statusCode: statusCode);
    }

    if (statusCode == 401 || statusCode == 403) {
      return AppException(
        message,
        type: ErrorType.unauthorized,
        statusCode: statusCode,
      );
    }

    if (statusCode == 404) {
      return AppException.notFound(message, statusCode: statusCode);
    }

    if (statusCode >= 400 && statusCode < 500) {
      return AppException.validation(message, statusCode: statusCode);
    }

    return AppException.server(message, statusCode: statusCode);
  }

  bool _isSuccessStatusCode(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  void _logDioError(DioException e, StackTrace s) {
    print('''
==== LOGIN SERVICE - DIO ERROR =====
Type       : ${e.type}
Message    : ${e.message}
Status Code: ${e.response?.statusCode}
Data       : ${e.response?.data}
Underlying : ${e.error}
StackTrace : $s
=====================================
''');
  }

  void _logGenericError(Object e, StackTrace s) {
    print('''
===== LOGIN SERVICE - UNKNOWN ERROR =====
Error     : $e
StackTrace: $s
========================================
''');
  }
}
