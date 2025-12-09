import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../data/remote/models/remote/login_response.dart';
import '../../constants/enums/enums.dart';
import '../../dio/token_refresh_interceptor.dart';
import '../../network/api_constants.dart';

extension TokenRefreshMethods on TokenRefreshInterceptor {
  Future<Map<String, String>?> refreshTokens(String refreshToken) async {
    try {
      log(
        '[refreshTokens] Preparing token renewal request...',
        name: 'TokenRefreshInterceptor',
      );
      log(
        '[refreshTokens] Refresh token used (partial): ${refreshToken.substring(0, 10)}...',
        name: 'TokenRefreshInterceptor',
      );
      log(
        '[refreshTokens] Refresh URL: ${ApiConstants.refresh}',
        name: 'TokenRefreshInterceptor',
      );

      final response = await refreshDio.post(
        ApiConstants.refresh,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept-Language': 'az',
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      log(
        '[refreshTokens] Renewal request made. StatusCode: ${response.statusCode}',
        name: 'TokenRefreshInterceptor',
      );
      log(
        '[refreshTokens] Return data: ${response.data}',
        name: 'TokenRefreshInterceptor',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        final newRole = data['role'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          log(
            '[refreshTokens] New accessToken and refreshToken received.',
            name: 'TokenRefreshInterceptor',
          );

          final currentLoginResponse = loginLocalService.loginResponse;
          if (currentLoginResponse != null) {
            log(
              '[refreshTokens] loginResponse is being updated...',
              name: 'TokenRefreshInterceptor',
            );

            final roleToUse = newRole != null
                ? UserRole.fromString(newRole)
                : currentLoginResponse.role;

            final updatedLoginResponse = LoginResponse(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              name: currentLoginResponse.name,
              surname: currentLoginResponse.surname,
              role: roleToUse,
              userId: data['userId'] as int?,
              message: data['message'] as String?,
            );

            await loginLocalService.saveLoginResponse(updatedLoginResponse);

            log(
              '[refreshTokens] LoginResponse updated with role: ${roleToUse.displayName}',
              name: 'TokenRefreshInterceptor',
            );
          } else {
            log(
              '[refreshTokens] Creating new LoginResponse from refresh data...',
              name: 'TokenRefreshInterceptor',
            );

            final roleToUse = newRole != null
                ? UserRole.fromString(newRole)
                : _extractRoleFromToken(newAccessToken) ?? UserRole.guest;

            final newLoginResponse = LoginResponse(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              name: data['name'] as String? ?? '',
              surname: data['surname'] as String? ?? '',
              role: roleToUse,
              userId: data['userId'] as int?,
              message: data['message'] as String?,
            );

            await loginLocalService.saveLoginResponse(newLoginResponse);

            log(
              '[refreshTokens] New LoginResponse created with role: ${roleToUse.displayName}',
              name: 'TokenRefreshInterceptor',
            );
          }

          return {
            'accessToken': newAccessToken,
            'refreshToken': newRefreshToken,
          };
        }
      }
    } catch (e, stackTrace) {
      log(
        '[refreshTokens] Error during token refresh request: $e',
        name: 'TokenRefreshInterceptor',
        stackTrace: stackTrace,
      );
      if (e is DioException) {
        log(
          '[refreshTokens] Error statusCode: ${e.response?.statusCode}',
          name: 'TokenRefreshInterceptor',
        );
        log(
          '[refreshTokens] Error response data: ${e.response?.data}',
          name: 'TokenRefreshInterceptor',
        );
      }
    }
    return null;
  }

  UserRole? _extractRoleFromToken(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);

      final Map<String, dynamic> tokenData = jsonDecode(decodedString);
      final roleStr = tokenData['role'] as String?;

      if (roleStr != null) {
        log(
          '[_extractRoleFromToken] Role extracted from token: $roleStr',
          name: 'TokenRefreshInterceptor',
        );
        return UserRole.fromString(roleStr);
      }
    } catch (e) {
      log(
        '[_extractRoleFromToken] Error extracting role from token: $e',
        name: 'TokenRefreshInterceptor',
      );
    }
    return null;
  }

  Future<Response> retryRequest(
      RequestOptions options,
      String newAccessToken,
      ) async {
    log(
      '[retryRequest] Retrying the request. Path: ${options.path}',
      name: 'TokenRefreshInterceptor',
    );
    final newOptions = Options(
      method: options.method,
      headers: {...options.headers, 'Authorization': 'Bearer $newAccessToken'},
    );

    return await refreshDio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: newOptions,
    );
  }

  Future<void> processPendingRequests(String newAccessToken) async {
    log(
      '[processPendingRequests] Requests in the queue are being processed. Count: ${pendingRequests.length}',
      name: 'TokenRefreshInterceptor',
    );
    final requests = List<RequestOptionsWrapper>.from(pendingRequests);
    pendingRequests.clear();

    for (final pendingRequest in requests) {
      try {
        log(
          '[processPendingRequests] Trying again - pending request: ${pendingRequest.options.path}',
          name: 'TokenRefreshInterceptor',
        );
        final response = await retryRequest(
          pendingRequest.options,
          newAccessToken,
        );
        pendingRequest.handler.resolve(response);
        log(
          '[processPendingRequests] Process Successfully Completed: ${pendingRequest.options.path}',
          name: 'TokenRefreshInterceptor',
        );
      } catch (e, stackTrace) {
        log(
          '[processPendingRequests] Request failed after refresh: $e',
          name: 'TokenRefreshInterceptor',
          stackTrace: stackTrace,
        );
        pendingRequest.handler.reject(
          DioException(requestOptions: pendingRequest.options, error: e),
        );
      }
    }
  }

  void rejectPendingRequests(DioException originalError) {
    log(
      '[rejectPendingRequests] All requests in the queue are rejected. Count: ${pendingRequests.length}',
      name: 'TokenRefreshInterceptor',
    );
    final requests = List<RequestOptionsWrapper>.from(pendingRequests);
    pendingRequests.clear();

    for (final pendingRequest in requests) {
      pendingRequest.handler.reject(originalError);
      log(
        '[rejectPendingRequests] Request rejected: ${pendingRequest.options.path}',
        name: 'TokenRefreshInterceptor',
      );
    }
  }

  static RequestOptionsWrapper createRequestWrapper(
      RequestOptions options,
      ErrorInterceptorHandler handler,
      ) {
    return RequestOptionsWrapper(options, handler);
  }
}

class RequestOptionsWrapper {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  RequestOptionsWrapper(this.options, this.handler);
}
