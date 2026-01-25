import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../data/remote/services/remote/auth_manager_services.dart';
import '../../../data/remote/services/remote/pin_local_service.dart';
import '../../../utils/di/locator.dart';

class PinEntryPage extends HookWidget {
  final AuthState targetAuthState;
  final VoidCallback onPinVerified;

  const PinEntryPage({
    super.key,
    required this.targetAuthState,
    required this.onPinVerified,
  });

  @override
  Widget build(BuildContext context) {
    final pinLocalService = locator<PinLocalService>();
    final pinController = useTextEditingController();
    final errorMessage = useState<String?>(null);
    final isLoading = useState(false);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Colors.black, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Colors.red, width: 2),
      ),
    );

    void verifyPin(String pin) {
      isLoading.value = true;
      errorMessage.value = null;

      Future.delayed(const Duration(milliseconds: 300), () {
        final isValid = pinLocalService.verifyPin(pin);

        if (isValid) {
          onPinVerified();
        } else {
          errorMessage.value = AppTranslation.translate(AppStrings.wrongPinTryAgain);
          pinController.clear();
          isLoading.value = false;
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/settings_pass_ico.svg',
                  width: 85,
                  height: 85,
                ),
                const SizedBox(height: 32),
                Text(
                  AppTranslation.translate(AppStrings.enterYourPin),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslation.translate(AppStrings.enterPinToContinue),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Pinput(
                  controller: pinController,
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorMessage.value != null ? errorPinTheme : null,
                  obscureText: true,
                  obscuringCharacter: '●',
                  enabled: !isLoading.value,
                  onCompleted: verifyPin,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                if (errorMessage.value != null)
                  Text(
                    errorMessage.value!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                if (isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}