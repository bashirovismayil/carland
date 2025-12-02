
import '../../core/constants/enums/enums.dart';

class AppException implements Exception {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final dynamic originalError;

  AppException(
      this.message, {
        required this.type,
        this.statusCode,
        this.originalError,
      });

  String get code {
    if (statusCode != null) {
      return '${type.name.toUpperCase()}_$statusCode';
    }
    return '${type.name.toUpperCase()}_ERROR';
  }

  @override
  String toString() => message;


  factory AppException.network(String message, {int? statusCode}) {
    return AppException(
      message,
      type: ErrorType.network,
      statusCode: statusCode,
    );
  }

  factory AppException.server(String message, {int? statusCode}) {
    return AppException(
      message,
      type: ErrorType.server,
      statusCode: statusCode,
    );
  }

  factory AppException.unauthorized({int statusCode = 401}) {
    return AppException(
      'İcazəsiz giriş: Zəhmət olmasa yenidən daxil olun',
      type: ErrorType.unauthorized,
      statusCode: statusCode,
    );
  }

  factory AppException.notFound(String message, {int statusCode = 404}) {
    return AppException(
      message,
      type: ErrorType.notFound,
      statusCode: statusCode,
    );
  }

  factory AppException.validation(String message, {int? statusCode}) {
    return AppException(
      message,
      type: ErrorType.validation,
      statusCode: statusCode,
    );
  }

  factory AppException.timeout({int statusCode = 504}) {
    return AppException(
      'Bağlantı vaxtı bitdi: Zəhmət olmasa internetinizi yoxlayın',
      type: ErrorType.timeout,
      statusCode: statusCode,
    );
  }

  factory AppException.unknown([dynamic error]) {
    return AppException(
      'Gözlənilməz xəta baş verdi',
      type: ErrorType.unknown,
      originalError: error,
    );
  }

  bool isType(ErrorType errorType) => type == errorType;

  bool hasStatusCode(int code) => statusCode == code;
}