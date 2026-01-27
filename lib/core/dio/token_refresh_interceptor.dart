import 'dart:developer';
import 'dart:ui';
import 'package:dio/dio.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../data/remote/services/local/register_local_service.dart';
import '../extensions/auth_extensions/refresh_methods_extension.dart';

class TokenRefreshInterceptor extends Interceptor {
  final LoginLocalService _loginLocalService;
  final RegisterLocalService _registerLocalService;
  final Dio _refreshDio;
  final VoidCallback? onTokenExpired;
  bool _isRefreshing = false;
  final List<RequestOptionsWrapper> _pendingRequests = [];

  TokenRefreshInterceptor(
      this._loginLocalService,
      this._registerLocalService,{
        this.onTokenExpired,
      }) : _refreshDio = Dio();

  LoginLocalService get loginLocalService => _loginLocalService;
  RegisterLocalService get registerLocalService => _registerLocalService;

  Dio get refreshDio => _refreshDio;

  List<RequestOptionsWrapper> get pendingRequests => _pendingRequests;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('[onRequest] Token check.', name: 'TokenRefreshInterceptor');

    final skipTokenRefresh = options.headers['X-Skip-Token-Refresh'] == 'true';

    if (skipTokenRefresh) {
      log('[onRequest] Skip token refresh detected', name: 'TokenRefreshInterceptor');
      options.headers.remove('X-Skip-Token-Refresh');
      final registerToken = _registerLocalService.registerToken;
      if (registerToken != null && registerToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $registerToken';
        log(
          '[onRequest] Register token added: Bearer ${registerToken.substring(0, 10)}...',
          name: 'TokenRefreshInterceptor',
        );
      } else {
        log('[onRequest] Register token not found', name: 'TokenRefreshInterceptor');
      }

      handler.next(options);
      return;
    }

    final accessToken = _loginLocalService.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      log(
        '[onRequest] Authorization header added: Bearer ${accessToken.substring(0, 10)}...',
        name: 'TokenRefreshInterceptor',
      );
    } else {
      log(
        '[onRequest] Token not found or empty.',
        name: 'TokenRefreshInterceptor',
      );
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log(
      '[onError] Error. StatusCode: ${err.response?.statusCode}',
      name: 'TokenRefreshInterceptor',
    );
    final skipTokenRefresh = err.requestOptions.headers['X-Skip-Token-Refresh'] == 'true';
    if (skipTokenRefresh) {
      log(
        '[onError] Skip token refresh flag detected - no refresh will be attempted',
        name: 'TokenRefreshInterceptor',
      );
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401) {
      log(
        '[onError] 401 Unauthorized error. Token refresh flow is starting:',
        name: 'TokenRefreshInterceptor',
      );
      final refreshToken = _loginLocalService.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        log(
          '[onError] Refresh token not found or empty. User will be forced to log out:',
          name: 'TokenRefreshInterceptor',
        );
        await _loginLocalService.clear();
        onTokenExpired?.call();
        handler.reject(err);
        return;
      }

      if (_isRefreshing) {
        log(
          '[onError] Token renewal is currently in progress. The request is being added to the queue:',
          name: 'TokenRefreshInterceptor',
        );
        _pendingRequests.add(
          TokenRefreshMethods.createRequestWrapper(err.requestOptions, handler),
        );
        return;
      }

      try {
        _isRefreshing = true;
        log(
          '[onError] Token renewal process has started:',
          name: 'TokenRefreshInterceptor',
        );

        final newTokens = await refreshTokens(refreshToken);

        if (newTokens != null) {
          log(
            '[onError] New tokens received. AccessToken: ${newTokens['accessToken']!.substring(0, 10)}...',
            name: 'TokenRefreshInterceptor',
          );
          try {
            final response = await retryRequest(
              err.requestOptions,
              newTokens['accessToken']!,
            );
            log(
              '[onError] Original request successfully reprocessed. StatusCode: ${response.statusCode}',
              name: 'TokenRefreshInterceptor',
            );
            handler.resolve(response);
          } on DioException catch (retryError) {
            if (retryError.response?.statusCode != null &&
                [
                  400,
                  404,
                  422,
                  409,
                ].contains(retryError.response?.statusCode)) {
              log(
                '[onError] Business logic error after retry (${retryError.response?.statusCode}), rejecting with original error',
                name: 'TokenRefreshInterceptor',
              );
              handler.reject(retryError);
              return;
            }
            rethrow;
          }

          await processPendingRequests(newTokens['accessToken']!);
        } else {
          log(
            '[onError] Refresh token not found or empty. User will be forced to log out:',
            name: 'TokenRefreshInterceptor',
          );
          await _loginLocalService.clear();
          onTokenExpired?.call();
          handler.reject(err);
          rejectPendingRequests(err);
        }
      } catch (e, stackTrace) {
        log(
          '[onError] An unexpected error occurred during token refresh: $e',
          name: 'TokenRefreshInterceptor',
          stackTrace: stackTrace,
        );
        await _loginLocalService.clear();
        onTokenExpired?.call();
        handler.reject(err);
        rejectPendingRequests(err);
      } finally {
        _isRefreshing = false;
        log(
          '[onError] Token renewal process completed!',
          name: 'TokenRefreshInterceptor',
        );
      }
    } else {
      log(
        '[onError] The error is not 401, the flow continues normally:',
        name: 'TokenRefreshInterceptor',
      );
      handler.next(err);
    }
  }
}
