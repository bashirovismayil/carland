import 'dart:async';

import '../../../../core/constants/enums/enums.dart';
import '../local/login_local_services.dart';

class AuthManagerService {
  AuthManagerService(this._loginLocalService);

  final LoginLocalService _loginLocalService;

  final _authStateController = StreamController<AuthState>.broadcast();

  Stream<AuthState> get authStateStream => _authStateController.stream;

  AuthState get currentAuthState {
    if (!_loginLocalService.isAuthenticated) {
      return AuthState.unauthenticated;
    }

    final role = _loginLocalService.currentUserRole;
    switch (role) {
      case UserRole.guest:
        return AuthState.guest;
      case UserRole.user:
        return AuthState.authenticatedUser;
      case UserRole.admin:
        return AuthState.authenticatedAdmin;
      case UserRole.superAdmin:
        return AuthState.authenticatedSuperUser;
      case UserRole.boss:
        return AuthState.authenticatedBoss;
    }
  }

  Future<void> onLoginSuccess() async {
    _authStateController.add(currentAuthState);
  }

  Future<void> logout() async {
    await _loginLocalService.logout();
    _authStateController.add(AuthState.unauthenticated);
  }

  Future<void> enterGuestMode() async {
    await _loginLocalService.setGuestMode(true);
    _authStateController.add(AuthState.guest);
  }

  bool canAccess(List<UserRole> allowedRoles) {
    return allowedRoles.contains(_loginLocalService.currentUserRole);
  }

  bool get canViewAdminPanel => _loginLocalService.canViewAdminPanel;
  bool get canViewUserFeatures => _loginLocalService.canViewUserFeatures;
  bool get isSuperUser => _loginLocalService.isSuperUser;
  bool get isGuest => _loginLocalService.isGuest;

  UserRole get currentRole => _loginLocalService.currentUserRole;
  String get homeRoute => _loginLocalService.getHomeRoute();

  void dispose() {
    _authStateController.close();
  }
}

enum AuthState {
  unauthenticated,
  guest,
  authenticatedUser,
  authenticatedAdmin,
  authenticatedSuperUser,
  authenticatedBoss,
}