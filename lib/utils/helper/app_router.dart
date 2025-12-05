import 'package:flutter/material.dart';
import '../../data/remote/services/remote/auth_manager_services.dart';
import '../../presentation/auth/auth_page.dart';
import '../../presentation/boss/boss_home_nav.dart';
import '../../presentation/introduction/onboard_page.dart';
import '../../presentation/user/user_main_nav.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey;

  AppRouter(this._navigatorKey);

  static final _routeMapping = <AuthState, Widget Function()>{
    AuthState.unauthenticated: () => const AuthPage(),
    AuthState.authenticatedBoss: () => const BossHomeNavigation(),
    AuthState.authenticatedUser: () => const UserMainNavigationPage(),
  };

  Widget getOnboardPage() => const OnboardPage();

  Widget getPageForAuthState(AuthState authState) {
    final pageBuilder = _routeMapping[authState];
    return pageBuilder?.call() ?? const _ErrorPage();
  }

  void navigateToAuthState(AuthState authState) {
    final targetPage = getPageForAuthState(authState);
    final targetRouteName = targetPage.runtimeType.toString();

    if (_navigatorKey.currentContext == null) return;

    final currentRoute = ModalRoute.of(_navigatorKey.currentContext!)?.settings.name;
    if (currentRoute == targetRouteName) return;

    _navigatorKey.currentState?.pushAndRemoveUntil(
      _createRoute(targetPage, targetRouteName),
          (route) => false,
    );
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