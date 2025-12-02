import 'package:flutter/material.dart';
import '../../../core/constants/enums/enums.dart';
import '../../../data/remote/models/remote/login_response.dart';

class LoginState {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final LoginStatus status;
  final String? errorMessage;
  final UserRole? userRole;
  final LoginResponse? response;

  LoginState({
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.userRole,
    this.response,
  });

  factory LoginState.initial() => LoginState(
    formKey: GlobalKey<FormState>(),
    phoneController: TextEditingController(),
    passwordController: TextEditingController(),
  );

  LoginState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? phoneController,
    TextEditingController? passwordController,
    LoginStatus? status,
    String? errorMessage,
    UserRole? userRole,
    LoginResponse? response,
  }) {
    return LoginState(
      formKey: formKey ?? this.formKey,
      phoneController: phoneController ?? this.phoneController,
      passwordController: passwordController ?? this.passwordController,
      status: status ?? this.status,
      errorMessage: errorMessage,
      userRole: userRole ?? this.userRole,
      response: response ?? this.response,
    );
  }

  bool get isLoading => status == LoginStatus.submitting;
  bool get isSuccess => status == LoginStatus.success;
  bool get isError => status == LoginStatus.error;
  bool get isGuestMode => status == LoginStatus.guestMode;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}
