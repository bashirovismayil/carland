import 'package:carcat/presentation/auth/register/widgets/register_buttons.dart';
import 'package:carcat/presentation/auth/register/widgets/register_form_validator.dart';
import 'package:carcat/presentation/auth/register/widgets/terms_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/cubit/auth/register/register_cubit.dart';
import '../../../../widgets/global_phone_input.dart';
import '../../../terms_and_privacy/privacy_policy.dart';
import '../../../terms_and_privacy/terms_page.dart';
import 'label_text_field.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.registerCubit,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    required this.agreeToTerms,
    required this.onAgreeToTermsChanged,
    required this.isLoading,
    required this.onSubmit,
    required this.onSignInTap,
  });

  final GlobalKey<FormState> formKey;
  final RegisterCubit registerCubit;
  final CountryCode selectedCountryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;
  final bool agreeToTerms;
  final ValueChanged<bool> onAgreeToTermsChanged;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onSignInTap;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const _RegisterLogo(),
          const SizedBox(height: 60),
          _RegisterHeader(
            title: context.currentLanguage(AppStrings.createAnAccount),
          ),
          const SizedBox(height: 32),
          NameField(
            label: context.currentLanguage(AppStrings.nameLabel),
            hintText: context.currentLanguage(AppStrings.nameHint),
            controller: registerCubit.nameController,
            validator: (value) => FormValidators.name(context, value),
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          NameField(
            label: context.currentLanguage(AppStrings.surnameLabel),
            hintText: context.currentLanguage(AppStrings.surnameHint),
            controller: registerCubit.surnameController,
            validator: (value) => FormValidators.surname(context, value),
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          GlobalPhoneInput(
            controller: registerCubit.phoneController,
            selectedCountryCode: selectedCountryCode,
            onCountryCodeChanged: onCountryCodeChanged,
            validator: (value) => FormValidators.phone(context, value),
            enabled: !isLoading,
          ),
          const SizedBox(height: 22),
          TermsCheckbox(
            value: agreeToTerms,
            onChanged: onAgreeToTermsChanged,
            agreementText: context.currentLanguage(AppStrings.iAgreeToThe),
            termsText: context.currentLanguage(AppStrings.termsOfService),
            privacyText: context.currentLanguage(AppStrings.privacyPolicy),
            onTermsTap: () => _navigateToTerms(context),
            onPrivacyTap: () => _navigateToPrivacy(context),
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            text: context.currentLanguage(AppStrings.continueButtonText),
            onPressed: onSubmit,
            isLoading: isLoading,
          ),
          const SizedBox(height: 17),
          TextLinkRow(
            leadingText: context.currentLanguage(AppStrings.alreadyHaveAccount),
            linkText: context.currentLanguage(AppStrings.signInButton),
            onLinkTap: onSignInTap,
          ),
        ],
      ),
    );
  }

  void _navigateToTerms(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TermsConditionsPage(),
      ),
    );
  }

  void _navigateToPrivacy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }
}
class _RegisterLogo extends StatelessWidget {
  const _RegisterLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/svg/carcat_full_logo.svg',
        height: 50,
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}