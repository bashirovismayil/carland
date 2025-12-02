import 'package:carland/core/localization/app_translation.dart';
import 'package:carland/presentation/auth/login/login_page.dart';
import 'package:carland/presentation/auth/register/register_page.dart';
import 'package:carland/utils/helper/go.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../widgets/custom_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 12),
              SvgPicture.asset(
                'assets/svg/carcat_full_logo.svg',
                height: 70,
              ),

              const Spacer(flex: 7),
              Text(
                context.currentLanguage(AppStrings.welcomeToCarland),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                context.currentLanguage(AppStrings.welcomeSubtitle),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // Login Button
              CustomElevatedButton(
                onPressed: () {
                 Go.replace(context, LoginPage());
                },
                width: double.infinity,
                height: 56,
                backgroundColor: const Color(0xFF282828),
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(32),
                elevation: 0,
                child: Text(
                  context.currentLanguage(AppStrings.loginButton),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomElevatedButton(
                onPressed: () {
                 Go.to(context, RegisterPage());
                },
                width: double.infinity,
                height: 56,
                backgroundColor: const Color(0xFFF1F1F1),
                foregroundColor: Colors.black,
                borderRadius: BorderRadius.circular(32),
                elevation: 0,
                child: Text(
                  context.currentLanguage(AppStrings.signUpButton),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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