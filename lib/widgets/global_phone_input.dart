import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/core/extensions/auth_extensions/phone_number_formatter.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/extensions/auth_extensions/string_validators.dart';

import '../presentation/auth/register/widgets/app_input_decoration.dart';

class GlobalPhoneInput extends StatelessWidget {
  const GlobalPhoneInput({
    super.key,
    required this.controller,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    this.validator,
    this.enabled = true,
    this.countryCodeFlex = 4,
    this.phoneNumberFlex = 6,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textInputAction = TextInputAction.done,
  });

  final TextEditingController controller;

  final CountryCode selectedCountryCode;

  final ValueChanged<CountryCode> onCountryCodeChanged;

  final String? Function(String?)? validator;

  final bool enabled;

  final int countryCodeFlex;

  final int phoneNumberFlex;

  final AutovalidateMode autovalidateMode;

  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: countryCodeFlex,
          child: _CountryCodePicker(
            selectedCode: selectedCountryCode,
            enabled: enabled,
            onTap: () => _showCountryCodeBottomSheet(context),
          ),
        ),

        const SizedBox(width: 12),
        Expanded(
          flex: phoneNumberFlex,
          child: _PhoneNumberField(
            controller: controller,
            enabled: enabled,
            validator: validator ?? (value) => _defaultPhoneValidator(context, value),
            autovalidateMode: autovalidateMode,
            textInputAction: textInputAction,
          ),
        ),
      ],
    );
  }
  void _showCountryCodeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => CountryCodeBottomSheet(
        selectedCode: selectedCountryCode,
        onSelect: (code) {
          onCountryCodeChanged(code);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  String? _defaultPhoneValidator(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.currentLanguage(AppStrings.phoneRequired);
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 9) {
      return context.currentLanguage(AppStrings.phoneInvalidLength);
    }

    if (!digitsOnly.isValidPhone) {
      return context.currentLanguage(AppStrings.phoneInvalid);
    }

    if (!digitsOnly.isValidMobileOperatorCode) {
      return context.currentLanguage(AppStrings.phoneInvalidOperator);
    }

    return null;
  }
}

class _CountryCodePicker extends StatelessWidget {
  const _CountryCodePicker({
    required this.selectedCode,
    required this.enabled,
    required this.onTap,
  });

  final CountryCode selectedCode;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          context.currentLanguage(AppStrings.countryCodeLabel),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Picker Container
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: AppInputDecorations.countryCodeContainer,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  selectedCode.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCode.code,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField({
    required this.controller,
    required this.enabled,
    required this.validator,
    required this.autovalidateMode,
    required this.textInputAction,
  });

  final TextEditingController controller;
  final bool enabled;
  final String? Function(String?) validator;
  final AutovalidateMode autovalidateMode;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          context.currentLanguage(AppStrings.phoneNumberLabel),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Text Field
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textInputAction: textInputAction,
          enabled: enabled,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
            PhoneNumberFormatter.phoneFormatter,
          ],
          validator: validator,
          autovalidateMode: autovalidateMode,
          decoration: AppInputDecorations.phone(),
        ),
      ],
    );
  }
}
class CountryCodeBottomSheet extends StatelessWidget {
  const CountryCodeBottomSheet({
    super.key,
    required this.selectedCode,
    required this.onSelect,
  });

  final CountryCode selectedCode;
  final ValueChanged<CountryCode> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            context.currentLanguage(AppStrings.selectCountryCode),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Country List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CountryCode.values.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final code = CountryCode.values[index];
              final isSelected = code == selectedCode;

              return ListTile(
                onTap: () => onSelect(code),
                leading: Text(
                  code.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  code.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      code.code,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}