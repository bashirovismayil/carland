import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/values/app_theme.dart';
import 'shared_field_widgets.dart';

class CarTextField extends StatefulWidget {
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
  final AutovalidateMode? autovalidateMode;

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
    this.autovalidateMode,
  });

  @override
  State<CarTextField> createState() => _CarTextFieldState();
}

class _CarTextFieldState extends State<CarTextField> {
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncFormField);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFormField);
    super.dispose();
  }

  void _syncFormField() {
    final fieldState = _formFieldKey.currentState;
    if (fieldState != null && fieldState.value != widget.controller.text) {
      fieldState.didChange(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formFieldKey,
      initialValue: widget.controller.text,
      validator: widget.validator,
      autovalidateMode:
      widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: widget.label, isRequired: widget.isRequired),
          const SizedBox(height: AppTheme.spacingSm),
          InputContainer(
            enabled: widget.enabled,
            hasError: state.hasError,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              textCapitalization: widget.textCapitalization,
              maxLength: widget.maxLength,
              onChanged: (value) => state.didChange(value),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
              decoration: buildFieldDecoration(
                hint: widget.hint,
                svgIcon: widget.svgIcon,
                enabled: widget.enabled,
              ),
            ),
          ),
          if (state.hasError) FieldError(text: state.errorText!),
        ],
      ),
    );
  }
}