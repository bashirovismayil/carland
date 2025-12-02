import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/auth/login/login_cubit.dart';
import '../../../data/remote/services/local/register_local_service.dart';
import '../../../utils/di/locator.dart';
import '../../constants/enums/enums.dart';

extension AutoLoginExtension on BuildContext {

  Future<void> performAutoLogin({
    required String password,
    String? phoneNumber,
    String Function(String)? formatPhoneNumber,
  }) async {
    try {
      final loginData = await _prepareAutoLoginData(
        password: password,
        phoneNumber: phoneNumber,
        formatPhoneNumber: formatPhoneNumber,
      );

      if (!_isAutoLoginDataValid(loginData)) {
        log('Auto login failed: phoneNumber or password is empty');
        return;
      }

      final loginCubit = read<LoginCubit>();
      await loginCubit.performAutoLogin(
        phoneNumber: loginData.phoneNumber!,
        password: loginData.password!,
      );
    } catch (e, stackTrace) {
      log('Auto login extension error: $e', stackTrace: stackTrace);
    }
  }

  void handleAutoLoginState({
    required VoidCallback onSuccess,
    required Function(String?) onError,
  }) {
    final state = read<LoginCubit>().state;

    switch (state.status) {
      case LoginStatus.success:
        onSuccess();
        break;
      case LoginStatus.error:
        onError(state.errorMessage);
        break;
      default:
        break;
    }
  }

  Future<_AutoLoginData> _prepareAutoLoginData({
    required String password,
    String? phoneNumber,
    String Function(String)? formatPhoneNumber,
  }) async {
    final registerService = locator<RegisterLocalService>();

    String? loginPhoneNumber;

    if (phoneNumber != null) {
      loginPhoneNumber = formatPhoneNumber?.call(phoneNumber) ??
          _defaultFormatPhoneNumber(phoneNumber);
    } else {
      loginPhoneNumber = registerService.registeredPhoneNumber;
    }

    return _AutoLoginData(
      phoneNumber: loginPhoneNumber,
      password: password.isNotEmpty ? password : null,
    );
  }

  String _defaultFormatPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceFirst('+994', '');
  }

  bool _isAutoLoginDataValid(_AutoLoginData data) {
    return data.phoneNumber != null &&
        data.password != null &&
        data.phoneNumber!.isNotEmpty &&
        data.password!.isNotEmpty;
  }
}

class _AutoLoginData {
  final String? phoneNumber;
  final String? password;

  const _AutoLoginData({
    required this.phoneNumber,
    required this.password,
  });
}