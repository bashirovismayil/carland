import 'dart:io';
import 'package:carcat/core/constants/colors/app_colors.dart';
import 'package:carcat/presentation/auth/login/login_page.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../data/remote/services/remote/auth_manager_services.dart';
import '../../../data/remote/services/local/biometric_service.dart';
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

  static Duration get _biometricDelay {
    return Platform.isIOS
        ? const Duration(milliseconds: 1200)
        : const Duration(seconds: 1);
  }

  @override
  Widget build(BuildContext context) {
    final pinLocalService = locator<PinLocalService>();
    final biometricService = locator<BiometricService>();
    final pinController = useTextEditingController();
    final errorMessage = useState<String?>(null);
    final isLoading = useState(false);

    final isBiometricReady = useState(false);
    final showBiometricMode = useState(false);
    final biometricChecked = useState(false);

    // ── Biometric availability check & auto-trigger ──
    useEffect(() {
      if (biometricChecked.value) return null;
      biometricChecked.value = true;

      Future<void> initBiometric() async {
        if (!biometricService.isEnabled) return;

        final ready = await biometricService.isReadyToAuthenticate();
        if (!ready) return;

        isBiometricReady.value = true;
        showBiometricMode.value = true;

        // Platform'a göre gecikme ekle
        await Future.delayed(_biometricDelay);

        _triggerBiometric(
          biometricService: biometricService,
          onSuccess: onPinVerified,
          onFail: () {
            if (context.mounted) {
              errorMessage.value =
                  AppTranslation.translate(AppStrings.biometricFailed);
            }
          },
        );
      }

      initBiometric();
      return null;
    }, const []);

    // ── PIN themes ──
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

    // ── Handlers ──
    void verifyPin(String pin) {
      isLoading.value = true;
      errorMessage.value = null;

      Future.delayed(const Duration(milliseconds: 300), () {
        final isValid = pinLocalService.verifyPin(pin);

        if (isValid) {
          onPinVerified();
        } else {
          errorMessage.value =
              AppTranslation.translate(AppStrings.wrongPinTryAgain);
          pinController.clear();
          isLoading.value = false;
        }
      });
    }

    void handleCannotLogin() {
      pinLocalService.setBypassPinOnce();
      Go.replaceAndRemove(context, LoginPage());
    }

    void switchToBiometric() {
      errorMessage.value = null;
      showBiometricMode.value = true;

      // Manuel geçişte gecikme yok — kullanıcı zaten bekledi
      _triggerBiometric(
        biometricService: biometricService,
        onSuccess: onPinVerified,
        onFail: () {
          if (context.mounted) {
            errorMessage.value =
                AppTranslation.translate(AppStrings.biometricFailed);
          }
        },
      );
    }

    void switchToPin() {
      errorMessage.value = null;
      showBiometricMode.value = false;
      pinController.clear();
    }

    void showHelpDialog() {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.primaryWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Text(
                  AppTranslation.translate(AppStrings.helpText),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              AppTranslation.translate(AppStrings.helpInfoText),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  AppTranslation.translate(AppStrings.okButton),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      );
    }

    // ── UI ──
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
                  showBiometricMode.value
                      ? 'assets/svg/face_recognition_ico.svg'
                      : 'assets/svg/settings_pass_ico.svg',
                  width: 85,
                  height: 85,
                ),
                const SizedBox(height: 32),

                Text(
                  showBiometricMode.value
                      ? AppTranslation.translate(AppStrings.verifyIdentity)
                      : AppTranslation.translate(AppStrings.enterYourPin),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  showBiometricMode.value
                      ? AppTranslation.translate(AppStrings.scanFaceToLogin)
                      : AppTranslation.translate(AppStrings.enterPinToContinue),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ── Biometric Mode ──
                if (showBiometricMode.value) ...[
                  _BiometricActionButton(
                    onTap: () => _triggerBiometric(
                      biometricService: biometricService,
                      onSuccess: onPinVerified,
                      onFail: () {
                        if (context.mounted) {
                          errorMessage.value = AppTranslation.translate(
                              AppStrings.biometricFailed);
                        }
                      },
                    ),
                    svgPath: 'assets/svg/scanner_icon.svg',
                    label: AppTranslation.translate(AppStrings.tryAgain),
                  ),
                  const SizedBox(height: 16),

                  if (pinLocalService.hasPin)
                    _BiometricActionButton(
                      onTap: switchToPin,
                      icon: Icons.dialpad,
                      label: AppTranslation.translate(AppStrings.usePin),
                      isOutlined: true,
                    ),
                ],

                // ── PIN Mode ──
                if (!showBiometricMode.value) ...[
                  Pinput(
                    controller: pinController,
                    length: 4,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    errorPinTheme:
                    errorMessage.value != null ? errorPinTheme : null,
                    obscureText: true,
                    obscuringCharacter: '●',
                    enabled: !isLoading.value,
                    onCompleted: verifyPin,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),

                  if (isBiometricReady.value)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _BiometricActionButton(
                        onTap: switchToBiometric,
                        svgPath: 'assets/svg/scanner_icon.svg',
                        label:
                        AppTranslation.translate(AppStrings.useFaceId),
                        isOutlined: true,
                      ),
                    ),
                ],

                if (errorMessage.value != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      errorMessage.value!,
                      style:
                      const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: showHelpDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: handleCannotLogin,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Text(
                          AppTranslation.translate(AppStrings.iCannotLogin),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
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

  static void _triggerBiometric({
    required BiometricService biometricService,
    required VoidCallback onSuccess,
    required VoidCallback onFail,
  }) async {
    final success = await biometricService.authenticate(
      localizedReason:
      AppTranslation.translate(AppStrings.biometricLoginReason),
    );

    if (success) {
      onSuccess();
    } else {
      onFail();
    }
  }
}

class _BiometricActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData? icon;
  final String? svgPath;
  final String label;
  final bool isOutlined;

  const _BiometricActionButton({
    required this.onTap,
    required this.label,
    this.icon,
    this.svgPath,
    this.isOutlined = false,
  }) : assert(
  icon != null || svgPath != null,
  'Either icon or svgPath must be provided',
  );

  Widget _buildIcon(Color color) {
    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath!,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Icon(icon, size: 20, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isOutlined ? Colors.black87 : Colors.white;
    final iconWidget = _buildIcon(foregroundColor);

    return SizedBox(
      width: 220,
      height: 48,
      child: isOutlined
          ? OutlinedButton.icon(
        onPressed: onTap,
        icon: iconWidget,
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )
          : ElevatedButton.icon(
        onPressed: onTap,
        icon: iconWidget,
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}