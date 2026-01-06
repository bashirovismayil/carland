import 'package:flutter/material.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/cubit/auth/register/register_cubit.dart';
import 'package:carcat/cubit/auth/otp/otp_send_cubit.dart';
import 'package:carcat/utils/helper/go.dart';
import '../../otp/otp_page.dart';

class RegisterFormController {
  RegisterFormController({
    required this.context,
    required this.formKey,
    required this.registerCubit,
    required this.otpSendCubit,
    required this.selectedCountryCode,
    required this.setLoading,
  });

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final RegisterCubit registerCubit;
  final OtpSendCubit otpSendCubit;
  final CountryCode selectedCountryCode;
  final void Function(bool) setLoading;

  Future<void> handleSubmit({required bool agreeToTerms}) async {
    _unfocusKeyboard();

    if (!_validateForm()) return;

    if (!_checkTermsAccepted(agreeToTerms)) return;

    await _performRegistration();
  }

  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  bool _validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  bool _checkTermsAccepted(bool agreeToTerms) {
    if (!agreeToTerms) {
      _showErrorSnackBar(
        context.currentLanguage(AppStrings.pleaseAcceptTerms),
      );
      return false;
    }
    return true;
  }

  Future<void> _performRegistration() async {
    setLoading(true);

    await registerCubit.register();

    final state = registerCubit.state;

    if (state is RegisterError) {
      setLoading(false);
      _handleRegisterError(state);
      return;
    }

    if (state is RegisterNetworkError) {
      setLoading(false);
      _showErrorSnackBar(state.message);
      return;
    }

    if (state is RegisterSuccess) {
      await _handleRegisterSuccess();
      setLoading(false);
    }
  }

  void _handleRegisterError(RegisterError state) {
    if (state.message == "User already exists") {
      _showErrorSnackBar(
        context.currentLanguage(AppStrings.userAlreadyExists),
      );
    } else {
      _showErrorSnackBar(state.message);
    }
  }

  Future<void> _handleRegisterSuccess() async {
    if (!context.mounted) return;

    final phoneData = _preparePhoneData();

    await otpSendCubit.sendOtp(phoneData.forBackend);

    if (context.mounted) {
      _navigateToOtpPage(phoneData);
    }
  }

  ({String formatted, String forBackend}) _preparePhoneData() {
    final rawPhone = registerCubit.phoneController.text;
    final cleanPhone = rawPhone.replaceAll(RegExp(r'\D'), '');

    return (
    formatted: '${selectedCountryCode.code} $cleanPhone',
    forBackend: '${selectedCountryCode.dialCode}$cleanPhone',
    );
  }

  // Commented out - no longer needed as per product owner request
  // Future<bool?> _showOtpConfirmation(
  //     ({String formatted, String forBackend}) phoneData,
  //     ) {
  //   return OtpSendConfirmationDialog.show(
  //     context: context,
  //     phoneNumber: phoneData.formatted,
  //     onConfirm: () async {
  //       await otpSendCubit.sendOtp(phoneData.forBackend);
  //     },
  //   );
  // }

  void _navigateToOtpPage(({String formatted, String forBackend}) phoneData) {
    Go.to(
      context,
      OtpPage(
        phoneNumber: phoneData.forBackend,
        verifyType: OtpVerifyType.registration,
        countryCode: selectedCountryCode.code,
      ),
    );
  }

  void navigateToLogin() {
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
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
}