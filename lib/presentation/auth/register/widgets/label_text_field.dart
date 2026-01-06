import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_input_decoration.dart';

class UpperCaseFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String text = newValue.text;
    String newText = text[0].toUpperCase() + text.substring(1);
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
    );
  }
}

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.words,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.maxLength,
    this.onChanged,
    this.focusNode,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          enabled: enabled,
          inputFormatters: [
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
            ...?inputFormatters,
          ],
          validator: validator,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          decoration: prefixIcon != null
              ? AppInputDecorations.withPrefixIcon(
            hintText: hintText,
            prefixIcon: prefixIcon!,
          )
              : AppInputDecorations.simple(hintText: hintText),
        ),
      ],
    );
  }
}

class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool enabled;
  final TextInputAction textInputAction;

  static final RegExp namePattern = RegExp(
      r'[a-zA-ZığüşöçİĞÜŞÖÇəƏ'
      r'а-яА-ЯёЁ'
      r'\s]'
  );

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      prefixIcon: Icons.person_outline,
      validator: validator,
      enabled: enabled,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.words,
      maxLength: 50,
      inputFormatters: [
        FilteringTextInputFormatter.allow(namePattern),
        UpperCaseFirstLetterFormatter(),
      ],
    );
  }
}