import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/remote/services/local/login_local_services.dart';
import '../../../core/constants/enums/enums.dart';
import '../../../data/remote/contractor/login_contractor.dart';
import '../../../data/remote/services/remote/auth_manager_services.dart';
import '../../../utils/di/locator.dart';
import '../../../utils/helper/app_exceptions.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginContractor) : super(LoginState.initial());

  final LoginContractor _loginContractor;
  final _local = locator<LoginLocalService>();
  final _authManager = locator<AuthManagerService>();

  String _formatPhoneNumber(String phoneNumber) {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (!cleanedNumber.startsWith('994')) {
      cleanedNumber = '994$cleanedNumber';
    }
    return '+$cleanedNumber';
  }

  Future<void> submit() async {
    final form = state.formKey.currentState;
    if (form == null || !form.validate()) return;

    if (isClosed) return;

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      final formattedPhone = _formatPhoneNumber(state.phoneController.text);

      final resp = await _loginContractor.login(
        phoneNumber: formattedPhone,
        password: state.passwordController.text,
      );

      if (isClosed) return;

      await _local.saveLoginResponse(resp);
      await _authManager.onLoginSuccess();

      log(' - Login successful - Role: ${resp.role.displayName}');

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.success,
        userRole: resp.role,
        response: resp,
      ));
    } on AppException catch (e, s) {
      log('Login AppException: ${e.message}', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.message,
      ));
    } catch (e, s) {
      log('Login Exception', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Gözlənilməyən xəta baş verdi',
      ));
    }
  }

  Future<void> performAutoLogin({
    required String phoneNumber,
    required String password,
  }) async {
    if (isClosed) return;

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      final resp = await _loginContractor.login(
        phoneNumber: formattedPhone,
        password: password,
      );

      if (isClosed) return;

      await _local.saveLoginResponse(resp);
      await _authManager.onLoginSuccess();

      log(' - Auto login successful - Role: ${resp.role.displayName}');

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.success,
        userRole: resp.role,
        response: resp,
      ));
    } on AppException catch (e, s) {
      log('Auto Login AppException: ${e.message}', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.message,
      ));
    } catch (e, s) {
      log('Auto Login Exception', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Auto login xətası',
      ));
    }
  }

  Future<void> performGuestLogin({
    required String phoneNumber,
    required String password,
  }) async {
    if (isClosed) return;

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      await _local.clear();
      log('Guest login started - tokens cleared');

      final formattedPhone = _formatPhoneNumber(phoneNumber);

      final resp = await _loginContractor.login(
        phoneNumber: formattedPhone,
        password: password,
      );

      if (isClosed) return;

      await _local.saveLoginResponse(resp);
      await _local.setGuestMode(true);
      await _authManager.onLoginSuccess();

      log(' - Guest login successful - Role: ${resp.role.displayName}');

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.success,
        userRole: resp.role,
        response: resp,
      ));
    } on AppException catch (e, s) {
      log('Guest Login AppException: ${e.message}', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.message,
      ));
    } catch (e, s) {
      log('Guest Login Exception', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Guest login xətası',
      ));
    }
  }

  Future<void> enterPureGuestMode() async {
    try {
      await _local.clear();
      await _local.setGuestMode(true);
      await _authManager.enterGuestMode();

      if (isClosed) return;

      emit(state.copyWith(status: LoginStatus.guestMode));
      log(' - Pure guest mode activated');
    } catch (e, s) {
      log('Pure guest mode error', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> enterGuestMode() async {
    try {
      await _authManager.enterGuestMode();

      if (isClosed) return;

      emit(state.copyWith(status: LoginStatus.guestMode));
      log('Entered guest mode');
    } catch (e, s) {
      log('Guest mode error', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    state.phoneController.dispose();
    state.passwordController.dispose();
    return super.close();
  }
}