import 'dart:async';
import 'package:carland/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/enums/enums.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../cubit/auth/otp/otp_send_cubit.dart';
import '../../../cubit/auth/otp/otp_verify_cubit.dart';
import '../../../utils/helper/go.dart';
import '../password/setup_pass.dart';

class OtpPage extends HookWidget {
  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.verifyType,
    this.countryCode,
  });

  final String phoneNumber;
  final OtpVerifyType verifyType;
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    final pinController = useTextEditingController();
    final focusNode = useFocusNode();
    final hasError = useState(false);
    final isLoading = useState(false);
    final isOtpComplete = useState(false);

    final secondsRemaining = useState(120);
    final isTimerActive = useState(true);

    final otpVerifyCubit = context.read<OtpVerifyCubit>();
    final otpSendCubit = context.read<OtpSendCubit>();

    // Timer management - only depend on isTimerActive to avoid re-triggering
    useEffect(() {
      Timer? timer;
      if (isTimerActive.value && secondsRemaining.value > 0) {
        timer = Timer.periodic(const Duration(seconds: 1), (_) {
          secondsRemaining.value--;
          if (secondsRemaining.value <= 0) {
            isTimerActive.value = false;
            timer?.cancel();
          }
        });
      }
      return () => timer?.cancel();
    }, [isTimerActive.value]);


    String formatTimer(int seconds) {
      final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
      final secs = (seconds % 60).toString().padLeft(2, '0');
      return '$minutes:$secs';
    }

    // Safe phone number extraction for resend
    String extractRawPhoneNumber(String fullNumber) {
      // Remove all non-digit characters
      final digitsOnly = fullNumber.replaceAll(RegExp(r'\D'), '');

      // If we have a country code, try to extract using it
      if (countryCode != null) {
        // Get dial code from country code (e.g., +994 -> 994)
        final dialCode = countryCode!.replaceAll(RegExp(r'\D'), '');

        if (digitsOnly.startsWith(dialCode)) {
          return digitsOnly.substring(dialCode.length);
        }
      }

      // If the number is very long, assume it includes country code
      // Most country codes are 1-3 digits, local numbers are typically 7-10 digits
      if (digitsOnly.length > 10) {
        // Try to extract last 9-10 digits as the local number
        return digitsOnly.substring(digitsOnly.length - 9);
      }

      // Otherwise return as is
      return digitsOnly;
    }

    void showErrorSnackBar(String message) {
      if (!context.mounted) return;
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

    void showSuccessSnackBar(String message) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    void handleResendCode() {
      if (secondsRemaining.value > 0) {
        showErrorSnackBar(
          context.currentLanguage(AppStrings.waitBeforeResend),
        );
        return;
      }

      try {
        // For resend, we need to extract the raw phone number
        final rawPhone = extractRawPhoneNumber(phoneNumber);

        if (rawPhone.isEmpty) {
          showErrorSnackBar(
            context.currentLanguage(AppStrings.invalidPhoneNumber),
          );
          return;
        }

        // Send with full phone number (including country code)
        otpSendCubit.sendOtp(phoneNumber);

        secondsRemaining.value = 120;
        isTimerActive.value = true;

        showSuccessSnackBar(context.currentLanguage(AppStrings.otpResent));
      } catch (e) {
        showErrorSnackBar(
          context.currentLanguage(AppStrings.errorOccurred),
        );
      }
    }

    void handleNext() {
      if (pinController.text.length != 6) {
        showErrorSnackBar(
          context.currentLanguage(AppStrings.enterCompleteOtp),
        );
        return;
      }

      isLoading.value = true;
      otpVerifyCubit.otpCode = pinController.text;
      otpVerifyCubit.verifyOtp();
    }

    void handleBack() {
      if (!context.mounted) return;
      Navigator.pop(context);
    }

    void handleVerifySuccess() {
      if (!context.mounted) return;

      isLoading.value = false;
      hasError.value = false;

      switch (verifyType) {
        case OtpVerifyType.registration:
          Go.replace(
            context,
            SetupPasswordPage(),
          );
          break;
        case OtpVerifyType.passwordReset:
          Go.replace(
            context,
            SetupPasswordPage(),
          );
          break;
        case OtpVerifyType.phoneVerification:
          Navigator.pop(context, true);
          break;
        case OtpVerifyType.test:
          Go.replace(
            context,
            SetupPasswordPage(),
          );
          break;
      }
    }

    void handleVerifyError(String error) {
      if (!context.mounted) return;

      isLoading.value = false;
      hasError.value = true;
      pinController.clear();
      showErrorSnackBar(context.currentLanguage(AppStrings.wrongOtpCode));
    }

    final defaultPinTheme = PinTheme(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 2),
      ),
    );

    return BlocListener<OtpVerifyCubit, OtpVerifyState>(
      listener: (context, state) {
        if (state is OtpVerifySuccess) {
          handleVerifySuccess();
        } else if (state is OtpVerifyError) {
          handleVerifyError(state.message);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          // Cancel any pending operations on back press
          if (isLoading.value) {
            isLoading.value = false;
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        Row(
                          children: [
                            _buildBackButton(context),
                            Expanded(
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/svg/carcat_full_logo.svg',
                                  height: 45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 60),
                        _buildHeader(context),
                        const SizedBox(height: 15),
                        Text(
                          context.currentLanguage(AppStrings.otpSubtitle),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Pinput
                        Center(
                          child: Pinput(
                            controller: pinController,
                            focusNode: focusNode,
                            length: 6,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            submittedPinTheme: hasError.value
                                ? errorPinTheme
                                : submittedPinTheme,
                            errorPinTheme: errorPinTheme,
                            obscureText: true,
                            obscuringWidget: Container(
                              width: 15,
                              height: 15,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                            onChanged: (value) {
                              if (hasError.value) {
                                hasError.value = false;
                              }
                              isOtpComplete.value = value.length == 6;
                            },
                            keyboardType: TextInputType.number,
                            pinAnimationType: PinAnimationType.fade,
                            animationDuration:
                            const Duration(milliseconds: 200),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Timer - Separated widget to minimize rebuilds
                        _TimerDisplay(
                          secondsRemaining: secondsRemaining.value,
                        ),
                        const SizedBox(height: 16),
                        // Resend code row
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.currentLanguage(
                                    AppStrings.didntReceiveCode),
                                style: TextStyle(
                                  height: 1.4,
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: handleResendCode,
                                child: Text(
                                  context
                                      .currentLanguage(AppStrings.resendCode),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: secondsRemaining.value > 0
                                        ? Colors.grey.shade400
                                        : Colors.black,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Loading indicator
                        if (isLoading.value)
                          const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                        const Spacer(),
                        // Next button
                        _buildNextButton(
                          context,
                          isLoading: isLoading.value,
                          isEnabled: isOtpComplete.value,
                          onPressed: handleNext,
                        ),
                        const SizedBox(height: 16),
                        // Back button
                        _buildBackTextButton(context, handleBack),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: Colors.black87,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.currentLanguage(AppStrings.otpVerification),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(
      BuildContext context, {
        required bool isLoading,
        required bool isEnabled,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isLoading || !isEnabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF282828),
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          context.currentLanguage(AppStrings.nextButton),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBackTextButton(BuildContext context, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          backgroundColor: const Color(0xFFF1F1F1),
          foregroundColor: const Color(0xFF282828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          context.currentLanguage(AppStrings.backButton),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Separate widget for timer to minimize rebuilds
class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({
    required this.secondsRemaining,
  });

  final int secondsRemaining;

  String formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${formatTimer(secondsRemaining)} ${context.currentLanguage(AppStrings.secLeft)}',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}