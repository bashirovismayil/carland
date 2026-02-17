import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/values/app_theme.dart';
import 'shared_field_widgets.dart';

class CarTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? svgIcon;
  final bool enabled;
  final bool isRequired;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final int? maxLength;
  final FocusNode? focusNode;

  const CarTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.svgIcon,
    required this.enabled,
    this.isRequired = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.maxLength,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: label, isRequired: isRequired),
          const SizedBox(height: AppTheme.spacingSm),
          InputContainer(
            enabled: enabled,
            hasError: state.hasError,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textCapitalization: textCapitalization,
              maxLength: maxLength,
              onChanged: (value) => state.didChange(value),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
              decoration: buildFieldDecoration(
                hint: hint,
                svgIcon: svgIcon,
                enabled: enabled,
              ),
            ),
          ),
          if (state.hasError) FieldError(text: state.errorText!),
        ],
      ),
    );
  }
}