import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/core/extensions/auth_extensions/phone_number_formatter.dart';

import 'country_code_prefix.dart';
import 'login_styles.dart';
import 'login_validators.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.countryCodeNotifier,
    required this.isLoading,
    required this.onCountryCodeTap,
  });

  final TextEditingController controller;
  final ValueNotifier<CountryCode> countryCodeNotifier;
  final bool isLoading;
  final VoidCallback onCountryCodeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context),
        const SizedBox(height: 8),
        _buildTextField(context),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) => Text(
    context.currentLanguage(AppStrings.phoneLabel),
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _buildTextField(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.phone,
    textInputAction: TextInputAction.next,
    enabled: !isLoading,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(15),
      PhoneNumberFormatter.phoneFormatter,
    ],
    validator: (value) => PhoneValidator.validate(value, context),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      hintText: '70 123 45 67',
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: CountryCodePrefix(
        countryCodeNotifier: countryCodeNotifier,
        onTap: onCountryCodeTap,
      ),
      contentPadding: LoginInputDecoration.contentPadding(),
      border: LoginInputDecoration.defaultBorder(),
      enabledBorder: LoginInputDecoration.enabledBorder(),
      focusedBorder: LoginInputDecoration.focusedBorder(),
      errorBorder: LoginInputDecoration.errorBorder(),
      focusedErrorBorder: LoginInputDecoration.focusedErrorBorder(),
    ),
  );
}