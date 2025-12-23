import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/cubit/auth/login/login_state.dart';

mixin LoginStateHandler<T extends StatefulWidget> on State<T> {
  void handleLoginStateChange(BuildContext context, LoginState state) {
    if (state.isSuccess) {
      _handleLoginSuccess(state);
    } else if (state.isError && state.hasError) {
      _showErrorSnackBar(context, state.errorMessage!);
    } else if (state.isGuestMode) {
      _handleGuestMode();
    }
  }

  void _handleLoginSuccess(LoginState state) {
    final role = state.userRole;
    if (role == null) return;

    switch (role) {
      case UserRole.superAdmin:
      case UserRole.admin:
      case UserRole.boss:
      // Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case UserRole.user:
      // Navigator.pushReplacementNamed(context, '/home');
        break;
      case UserRole.guest:
      // Navigator.pushReplacementNamed(context, '/guest-home');
        break;
    }
  }

  void _handleGuestMode() {
    // Navigator.pushReplacementNamed(context, '/guest-home');
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showValidationError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(AppTranslation.translate(AppStrings.pleaseFillAllRequiredFields)),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}