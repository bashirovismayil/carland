import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'login_styles.dart';
import 'login_validators.dart';

class PasswordInputField extends StatelessWidget {
  const PasswordInputField({
    super.key,
    required this.controller,
    required this.obscureNotifier,
    required this.isLoading,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> obscureNotifier;
  final bool isLoading;
  final VoidCallback onSubmitted;

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
    context.currentLanguage(AppStrings.passwordLabel),
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _buildTextField(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: obscureNotifier,
      builder: (context, obscure, _) {
        return TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onFieldSubmitted: (_) => onSubmitted(),
          validator: (value) => PasswordValidator.validate(value, context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: '••••••••••••••',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: _buildPrefixIcon(),
            suffixIcon: _buildSuffixIcon(obscure),
            contentPadding: LoginInputDecoration.contentPadding(),
            border: LoginInputDecoration.defaultBorder(),
            enabledBorder: LoginInputDecoration.enabledBorder(),
            focusedBorder: LoginInputDecoration.focusedBorder(),
            errorBorder: LoginInputDecoration.errorBorder(),
            focusedErrorBorder: LoginInputDecoration.focusedErrorBorder(),
          ),
        );
      },
    );
  }

  Widget _buildPrefixIcon() => Padding(
    padding: const EdgeInsets.all(12.0),
    child: SvgPicture.asset(
      'assets/svg/password_icon.svg',
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn),
    ),
  );

  Widget _buildSuffixIcon(bool obscure) => IconButton(
    onPressed: () => obscureNotifier.value = !obscure,
    icon: Icon(
      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      size: 20,
      color: Colors.grey.shade500,
    ),
  );
}