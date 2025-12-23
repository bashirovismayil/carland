import 'package:carcat/presentation/auth/login/widgets/pass_info_field.dart';
import 'package:carcat/presentation/auth/login/widgets/phone_input_field.dart';
import 'package:carcat/presentation/auth/login/widgets/remember_me_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/cubit/auth/login/login_state.dart';
import 'forgot_password_button.dart';
import 'login_button.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.state,
    required this.countryCodeNotifier,
    required this.obscurePasswordNotifier,
    required this.rememberMeNotifier,
    required this.onCountryCodeTap,
    required this.onForgotPasswordTap,
    required this.onLoginPressed,
    required this.availableHeight,
  });

  final GlobalKey<FormState> formKey;
  final LoginState state;
  final ValueNotifier<CountryCode> countryCodeNotifier;
  final ValueNotifier<bool> obscurePasswordNotifier;
  final ValueNotifier<bool> rememberMeNotifier;
  final VoidCallback onCountryCodeTap;
  final VoidCallback onForgotPasswordTap;
  final VoidCallback onLoginPressed;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhoneInputField(
            controller: state.phoneController,
            countryCodeNotifier: countryCodeNotifier,
            isLoading: state.isLoading,
            onCountryCodeTap: onCountryCodeTap,
          ),
          const SizedBox(height: 20),
          PasswordInputField(
            controller: state.passwordController,
            obscureNotifier: obscurePasswordNotifier,
            isLoading: state.isLoading,
            onSubmitted: onLoginPressed,
          ),
          const SizedBox(height: 8),
          ForgotPasswordButton(onPressed: onForgotPasswordTap),
          const SizedBox(height: 13),
          RememberMeCheckbox(rememberMeNotifier: rememberMeNotifier),
          SizedBox(height: availableHeight * 0.20),
          LoginButton(isLoading: state.isLoading, onPressed: onLoginPressed),
        ],
      ),
    );
  }
}