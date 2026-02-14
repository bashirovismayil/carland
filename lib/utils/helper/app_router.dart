import 'package:flutter/material.dart';
import '../../data/remote/services/remote/auth_manager_services.dart';
import '../../data/remote/services/local/biometric_service.dart';
import '../../data/remote/services/remote/pin_local_service.dart';
import '../../presentation/auth/auth_page.dart';
import '../../presentation/auth/pin/pin_entry_page.dart';
import '../../presentation/boss/boss_home_nav.dart';
import '../../presentation/introduction/onboard_page.dart';
import '../../presentation/user/user_main_nav.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey;
  final PinLocalService _pinLocalService;
  final BiometricService _biometricService;

  AppRouter(this._navigatorKey, this._pinLocalService, this._biometricService);

  static final _routeMapping = <AuthState, Widget Function()>{
    AuthState.unauthenticated: () => const AuthPage(),
    AuthState.authenticatedBoss: () => const BossHomeNavigation(),
    AuthState.authenticatedUser: () => const UserMainNavigationPage(),
  };

  bool get _shouldAskSecurity {
    final needsPin = _pinLocalService.shouldAskPin;

    final needsBiometric = _biometricService.isEnabled &&
        !_pinLocalService.isSessionVerified &&
        _pinLocalService.shouldAskPin != false ||
        (_biometricService.isEnabled &&
            !_pinLocalService.isSessionVerified &&
            !_pinLocalService.hasPin);

    if (_pinLocalService.isBypassActive) return false;

    if (_pinLocalService.isSessionVerified) return false;

    return _pinLocalService.hasPin || _biometricService.isEnabled;
  }

  Widget getOnboardPage() => const OnboardPage();

  Widget getPageForAuthState(AuthState authState) {
    final pageBuilder = _routeMapping[authState];
    return pageBuilder?.call() ?? const _ErrorPage();
  }

  Widget getPageWithPinGuard(AuthState authState) {
    if (authState == AuthState.unauthenticated ||
        authState == AuthState.guest) {
      return getPageForAuthState(authState);
    }

    if (_shouldAskSecurity) {
      return PinEntryPage(
        targetAuthState: authState,
        onPinVerified: () {
          _pinLocalService.markSessionVerified();
          navigateToAuthState(authState);
        },
      );
    }

    return getPageForAuthState(authState);
  }

  void navigateToAuthState(AuthState authState) {
    final navigator = _navigatorKey.currentState;

    if (navigator == null || !navigator.mounted) {
      debugPrint(
          '[AppRouter] Navigator is null or not mounted, skipping navigation');
      return;
    }

    final context = _navigatorKey.currentContext;
    if (context == null) {
      debugPrint('[AppRouter] Navigator context is null, skipping navigation');
      return;
    }

    final targetPage = getPageWithPinGuard(authState);
    final targetRouteName = targetPage.runtimeType.toString();

    try {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == targetRouteName) {
        debugPrint('[AppRouter] Already on target page: $targetRouteName');
        return;
      }
    } catch (e) {
      debugPrint('[AppRouter] Error getting current route: $e');
    }

    try {
      navigator.pushAndRemoveUntil(
        _createRoute(targetPage, targetRouteName),
            (route) => false,
      );
      debugPrint('[AppRouter] Successfully navigated to: $targetRouteName');
    } catch (e, stackTrace) {
      debugPrint('[AppRouter] Navigation error: $e');
      debugPrint('[AppRouter] Stack trace: $stackTrace');

      try {
        navigator.push(_createRoute(targetPage, targetRouteName));
      } catch (e2) {
        debugPrint('[AppRouter] Fallback navigation also failed: $e2');
      }
    }
  }

  PageRoute<T> _createRoute<T extends Object?>(Widget page, String routeName) {
    return MaterialPageRoute<T>(
      builder: (_) => page,
      settings: RouteSettings(name: routeName),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Yüklənir...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Xəta ilə qarşılaşdıq',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Ən qısa zamanda həll edəcəyik'),
          ],
        ),
      ),
    );
  }
}