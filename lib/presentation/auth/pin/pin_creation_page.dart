import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../data/remote/services/remote/pin_local_service.dart';
import '../../../utils/di/locator.dart';

class PinCreationPage extends HookWidget {
  const PinCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pinLocalService = locator<PinLocalService>();
    final hasExistingPin = pinLocalService.hasPin;

    final currentStep = useState(hasExistingPin ? 0 : 1);
    final oldPinController = useTextEditingController();
    final newPinController = useTextEditingController();
    final confirmPinController = useTextEditingController();

    final errorMessage = useState<String?>(null);
    final isNewPinEnabled = useState(!hasExistingPin);

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

    void verifyOldPin(String pin) {
      final isValid = pinLocalService.verifyPin(pin);

      if (isValid) {
        currentStep.value = 1;
        isNewPinEnabled.value = true;
        errorMessage.value = null;
      } else {
        errorMessage.value = AppTranslation.translate(AppStrings.oldPinIncorrect);
        oldPinController.clear();
      }
    }

    void setNewPin(String pin) {
      if (currentStep.value == 1) {
        currentStep.value = 2;
        errorMessage.value = null;
      } else if (currentStep.value == 2) {
        if (newPinController.text == pin) {
          pinLocalService.setPin(pin);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslation.translate(AppStrings.pinCreatedSuccessfully)),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop();
        } else {
          errorMessage.value = AppTranslation.translate(AppStrings.pinCodesDoNotMatch);
          confirmPinController.clear();
        }
      }
    }

    void showRemovePinDialog() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppTranslation.translate(AppStrings.deletePin)),
          content: Text(
            AppTranslation.translate(AppStrings.deletePinConfirmation),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppTranslation.translate(AppStrings.cancel)),
            ),
            TextButton(
              onPressed: () async {
                await pinLocalService.removePin();
                Navigator.of(dialogContext).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppTranslation.translate(AppStrings.pinDeletedSuccessfully)),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(AppTranslation.translate(AppStrings.delete)),
            ),
          ],
        ),
      );
    }

    String getTitle() {
      if (currentStep.value == 0) return AppTranslation.translate(AppStrings.enterOldPin);
      if (currentStep.value == 1) return AppTranslation.translate(AppStrings.createNewPin);
      return AppTranslation.translate(AppStrings.confirmPin);
    }

    String getSubtitle() {
      if (currentStep.value == 0) return AppTranslation.translate(AppStrings.enterExistingPinToContinue);
      if (currentStep.value == 1) return AppTranslation.translate(AppStrings.createFourDigitPin);
      return AppTranslation.translate(AppStrings.reenterNewPin);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          hasExistingPin
              ? AppTranslation.translate(AppStrings.changePin)
              : AppTranslation.translate(AppStrings.createPin),
          style: const TextStyle(
            fontWeight: FontWeight.w700,),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SvgPicture.asset(
                  currentStep.value == 0
                      ? 'assets/svg/pin_unlocked_ico.svg'
                      : 'assets/svg/settings_pass_ico.svg',
                  width: 85,
                  height: 85,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                getTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                getSubtitle(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              if (currentStep.value == 0)
                Pinput(
                  controller: oldPinController,
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorMessage.value != null ? errorPinTheme : null,
                  obscureText: true,
                  obscuringCharacter: '●',
                  onCompleted: verifyOldPin,
                  autofocus: true,
                ),

              if (currentStep.value == 1)
                Pinput(
                  controller: newPinController,
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  obscureText: true,
                  obscuringCharacter: '●',
                  enabled: isNewPinEnabled.value,
                  onCompleted: setNewPin,
                  autofocus: isNewPinEnabled.value,
                ),

              if (currentStep.value == 2)
                Pinput(
                  controller: confirmPinController,
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorMessage.value != null ? errorPinTheme : null,
                  obscureText: true,
                  obscuringCharacter: '●',
                  onCompleted: setNewPin,
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

              if (hasExistingPin && currentStep.value == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: TextButton.icon(
                    onPressed: showRemovePinDialog,
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(
                      AppTranslation.translate(AppStrings.wantToRemovePinCompletely),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}