import 'package:carcat/presentation/auth/login/widgets/sign_up_section.dart';
import 'package:flutter/material.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/cubit/auth/login/login_state.dart';

import 'login_form.dart';
import 'login_header.dart';
import 'login_logo.dart';

class LoginScaffold extends StatelessWidget {
  const LoginScaffold({
    super.key,
    required this.formKey,
    required this.state,
    required this.countryCode,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onCountryCodeTap,
    required this.onForgotPasswordTap,
    required this.onSignUpTap,
    required this.onLoginPressed,
  });

  final GlobalKey<FormState> formKey;
  final LoginState state;
  final ValueNotifier<CountryCode> countryCode;
  final ValueNotifier<bool> obscurePassword;
  final ValueNotifier<bool> rememberMe;
  final VoidCallback onCountryCodeTap;
  final VoidCallback onForgotPasswordTap;
  final VoidCallback onSignUpTap;
  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) => _buildScrollView(constraints),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollView(BoxConstraints constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const LoginLogo(),
            const SizedBox(height: 50),
            const LoginHeader(),
            const SizedBox(height: 23),
            LoginForm(
              formKey: formKey,
              state: state,
              countryCodeNotifier: countryCode,
              obscurePasswordNotifier: obscurePassword,
              rememberMeNotifier: rememberMe,
              onCountryCodeTap: onCountryCodeTap,
              onForgotPasswordTap: onForgotPasswordTap,
              onLoginPressed: onLoginPressed,
              availableHeight: constraints.maxHeight,
            ),
            const SizedBox(height: 16),
            SignUpRow(onSignUpPressed: onSignUpTap),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}