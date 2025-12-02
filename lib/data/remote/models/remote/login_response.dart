
import '../../../../core/constants/enums/enums.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserRole role;
  final String? message;
  final int? userId;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    this.userId,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        role: UserRole.fromString(json['role'] ?? 'GUEST'),
        userId: json['userId'] ?? 0,
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'role': role.value,
        'userId': userId,
        'message': message,
      };

  UserRole get roleFromToken {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return role;

      return role;
    } catch (e) {
      return role;
    }
  }

  bool get isAuthenticated => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  bool get isGuest => role.isGuest;
}
