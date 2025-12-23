import 'package:carcat/presentation/auth/login/widgets/country_code_bottomsheet.dart';
import 'package:carcat/presentation/auth/login/widgets/login_scaffold.dart';
import 'package:carcat/presentation/auth/login/widgets/login_state_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/cubit/auth/login/login_cubit.dart';
import 'package:carcat/cubit/auth/login/login_state.dart';
import 'package:carcat/utils/helper/go.dart';
import '../forgot/forgot_password.dart';
import '../register/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginStateHandler {
  late final LoginCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _countryCode = ValueNotifier(CountryCode.azerbaijan);
  final _obscurePassword = ValueNotifier(true);
  final _rememberMe = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _cubit = context.read<LoginCubit>();
  }

  @override
  void dispose() {
    _countryCode.dispose();
    _obscurePassword.dispose();
    _rememberMe.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      _cubit.submit(countryCode: _countryCode.value, rememberMe: _rememberMe.value);
    } else {
      showValidationError(context);
    }
  }

  void _showCountryPicker() => showCountryCodeSheet(
    context: context,
    selectedCode: _countryCode.value,
    onSelect: (code) => _countryCode.value = code,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: handleLoginStateChange,
      builder: (context, state) => LoginScaffold(
        formKey: _formKey,
        state: state,
        countryCode: _countryCode,
        obscurePassword: _obscurePassword,
        rememberMe: _rememberMe,
        onCountryCodeTap: _showCountryPicker,
        onForgotPasswordTap: () => Go.to(context, ForgotPassword()),
        onSignUpTap: () => Go.to(context, RegisterPage()),
        onLoginPressed: _onLogin,
      ),
    );
  }
}