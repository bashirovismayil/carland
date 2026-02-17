import 'package:carcat/presentation/car/details/car_details_widgets/shared_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../utils/helper/capital_case_formatter.dart';

class ModelAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> modelNames;
  final bool isLoading;

  const ModelAutocompleteField({
    super.key,
    required this.controller,
    required this.modelNames,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppTranslation.translate(AppStrings.required);
        }
        return null;
      },
      builder: (fieldState) {
        _syncFieldState(fieldState);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(
              label: AppTranslation.translate(AppStrings.model),
              isRequired: true,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _AutocompleteInput(
              controller: controller,
              modelNames: modelNames,
              isLoading: isLoading,
              fieldState: fieldState,
            ),
            if (fieldState.hasError) FieldError(text: fieldState.errorText!),
          ],
        );
      },
    );
  }

  void _syncFieldState(FormFieldState<String> fieldState) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fieldState.value != controller.text) {
        fieldState.didChange(controller.text);
      }
    });
  }
}

class _AutocompleteInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> modelNames;
  final bool isLoading;
  final FormFieldState<String> fieldState;

  const _AutocompleteInput({
    required this.controller,
    required this.modelNames,
    required this.isLoading,
    required this.fieldState,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return const [];
        return modelNames.where(
              (name) => name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: (selected) {
        controller.text = selected;
        fieldState.didChange(selected);
      },
      fieldViewBuilder: _buildFieldView,
      optionsViewBuilder: _buildOptionsView,
    );
  }

  Widget _buildFieldView(
      BuildContext ctx,
      TextEditingController textController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted,
      ) {
    textController.addListener(() {
      controller.text = textController.text;
      fieldState.didChange(textController.text);
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: fieldState.hasError
              ? AppColors.errorColor
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        focusNode: focusNode,
        inputFormatters: [CapitalCaseFormatter()],
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 1,
        decoration: InputDecoration(
          hintText: isLoading
              ? 'Yüklənir...'
              : AppTranslation.translate(AppStrings.modelHint),
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/svg/car_model_icon.svg',
              color: AppColors.textSecondary,
              width: 20,
              height: 20,
            ),
          ),
          suffixIcon: isLoading ? _buildLoadingIndicator() : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingMd,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildOptionsView(
      BuildContext context,
      AutocompleteOnSelected<String> onSelected,
      Iterable<String> options,
      ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}