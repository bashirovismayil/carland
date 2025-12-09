import 'dart:developer';
import 'package:flutter/material.dart';
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

  String _formatPhoneNumber(String phoneNumber, CountryCode countryCode) {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final dialCode = countryCode.dialCode;

    debugPrint("🔵 _formatPhoneNumber:");
    debugPrint("   - Temizlenmiş numara: $cleanedNumber");
    debugPrint("   - Ülke kodu: ${countryCode.name}");
    debugPrint("   - Dial code: $dialCode");

    if (!cleanedNumber.startsWith(dialCode)) {
      cleanedNumber = '$dialCode$cleanedNumber';
    }

    final formattedPhone = '+$cleanedNumber';
    debugPrint("   - Formatlanmış: $formattedPhone");

    return formattedPhone;
  }

  Future<void> submit({
    required CountryCode countryCode,
    bool rememberMe = true,
  }) async {
    debugPrint("🟢 CUBIT: submit() metodu ÇAĞRILDI!");
    debugPrint("🔵 CUBIT: Phone = ${state.phoneController.text}");
    debugPrint("🔵 CUBIT: Password length = ${state.passwordController.text.length}");
    debugPrint("🔵 CUBIT: Country Code = ${countryCode.name} (${countryCode.dialCode})");
    debugPrint("🔵 CUBIT: Remember Me = $rememberMe");

    if (isClosed) return;

    debugPrint("🔵 CUBIT: Status = submitting olarak değiştiriliyor...");
    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      final formattedPhone = _formatPhoneNumber(
        state.phoneController.text,
        countryCode,
      );
      debugPrint("🔵 CUBIT: Formatted phone = $formattedPhone");

      debugPrint("🔵 CUBIT: API çağrısı başlıyor...");
      final resp = await _loginContractor.login(
        phoneNumber: formattedPhone,
        password: state.passwordController.text,
      );

      debugPrint("🟢 CUBIT: API response alındı!");

      if (isClosed) return;

      await _local.saveLoginResponse(resp);
      await _local.saveUserName(resp.name);
      await _local.saveUserSurname(resp.surname);
      await _local.setRememberMe(rememberMe);

      debugPrint(rememberMe
          ? "🟢 CUBIT: Remember Me AÇIK - Bilgiler KALICI kaydediliyor"
          : "🟡 CUBIT: Remember Me KAPALI - Bilgiler GEÇİCİ (app kapanınca silinecek)");

      await _authManager.onLoginSuccess();

      log('✅ Login successful - Role: ${resp.role.displayName}');
      debugPrint("🟢 CUBIT: Login BAŞARILI! Role = ${resp.role.displayName}");

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.success,
        userRole: resp.role,
        response: resp,
      ));

      debugPrint("🟢 CUBIT: State SUCCESS olarak güncellendi!");
    } on AppException catch (e, s) {
      log('❌ Login AppException: ${e.message}', stackTrace: s);
      debugPrint("🔴 CUBIT: AppException = ${e.message}");

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.message,
      ));
    } catch (e, s) {
      log('❌ Login Exception', error: e, stackTrace: s);
      debugPrint("🔴 CUBIT: Exception = $e");

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
    CountryCode countryCode = CountryCode.azerbaijan,
  }) async {
    if (isClosed) return;

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber, countryCode);

      final resp = await _loginContractor.login(
        phoneNumber: formattedPhone,
        password: password,
      );

      if (isClosed) return;

      await _local.saveLoginResponse(resp);
      await _local.saveUserName(resp.name);
      await _local.saveUserSurname(resp.surname);
      await _authManager.onLoginSuccess();

      log('✅ Auto login successful - Role: ${resp.role.displayName}');

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.success,
        userRole: resp.role,
        response: resp,
      ));
    } on AppException catch (e, s) {
      log('❌ Auto Login AppException: ${e.message}', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.message,
      ));
    } catch (e, s) {
      log('❌ Auto Login Exception', error: e, stackTrace: s);

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
    CountryCode countryCode = CountryCode.azerbaijan,
  }) async {
    if (isClosed) return;

    emit(state.copyWith(status: LoginStatus.submitting, errorMessage: null));

    try {
      await _local.clear();
      log('Guest login started - tokens cleared');

      final formattedPhone = _formatPhoneNumber(phoneNumber, countryCode);

      final resp = await _loginContractor.login(
        phoneNumber: formattedPhone,
        password: password,
      );

      if (isClosed) return;

      await _local.saveLoginResponse(resp);
      await _local.saveUserName(resp.name);
      await _local.saveUserSurname(resp.surname);
      await _local.setGuestMode(true);
      await _authManager.onLoginSuccess();

      log('✅ Guest login successful - Role: ${resp.role.displayName}');

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.success,
        userRole: resp.role,
        response: resp,
      ));
    } on AppException catch (e, s) {
      log('❌ Guest Login AppException: ${e.message}', stackTrace: s);

      if (isClosed) return;

      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: e.message,
      ));
    } catch (e, s) {
      log('❌ Guest Login Exception', error: e, stackTrace: s);

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
      log('✅ Pure guest mode activated');
    } catch (e, s) {
      log('❌ Pure guest mode error', error: e, stackTrace: s);

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
      log('✅ Entered guest mode');
    } catch (e, s) {
      log('❌ Guest mode error', error: e, stackTrace: s);

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