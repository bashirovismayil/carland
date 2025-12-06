import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../core/localization/app_translation.dart';

class SuccessPage extends StatelessWidget {
  final bool isRegister;
  final bool isPasswordReset;
  final bool isCarAdded;
  final String? carModel;
  final VoidCallback? onButtonPressed;

  const SuccessPage({
    super.key,
    this.isRegister = false,
    this.isPasswordReset = false,
    this.isCarAdded = false,
    this.carModel,
    this.onButtonPressed,
  });

  String get _title {
    if (isRegister) {
      return AppTranslation.translate(AppStrings.registrationSuccessful);
    } else if (isPasswordReset) {
      return AppTranslation.translate(AppStrings.passwordResetSuccessful);
    } else if (isCarAdded) {
      return AppTranslation.translate(AppStrings.carAdded);
    }
    return AppTranslation.translate(AppStrings.registrationSuccessful);
  }

  String get _subtitle {
    if (isCarAdded && carModel != null) {
      return '${AppTranslation.translate(AppStrings.newCarAdded)} $carModel';
    }
    return AppTranslation.translate(AppStrings.registrationSuccessSubtext);
  }

  String get _buttonText {
    if (isCarAdded) {
      return AppTranslation.translate(AppStrings.checkMyCars);
    }
    return AppTranslation.translate(AppStrings.gotIt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              const SizedBox(height: 60),
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.center,
              ),

              if (isCarAdded && carModel != null) ...[
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9E9E9E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 40),

              // Success Car Icon
              Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/success_car.svg',
                    width: 180,
                    height: 180,
                  ),
                ),
              ),

              const Spacer(),

              // Subtitle Text (for non-car-added cases)
              if (!isCarAdded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    isPasswordReset
                        ? AppTranslation.translate(
                            AppStrings.passwordResetSuccessSubtext)
                        : AppTranslation.translate(
                            AppStrings.registrationSuccessSubtext),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9E9E9E),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 40),

              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      onButtonPressed ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D2D2D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
