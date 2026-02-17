import 'package:flutter/material.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../cubit/body/type/get_body_type_state.dart';
import '../../../../cubit/color/get_color_list_state.dart';
import '../../../../cubit/engine/type/get_engine_type_state.dart';
import '../../../../cubit/transmission/type/tranmission_type_state.dart';
import '../../../../cubit/year/list/get_year_list_state.dart';
import 'dropdown_menu_helper.dart';
import 'shared_field_widgets.dart';

class CarDropdownField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? svgIcon;
  final bool enabled;
  final bool isRequired;
  final GlobalKey dropdownKey;
  final VoidCallback? onTap;
  final dynamic state;
  final List<String> Function(dynamic state) itemsExtractor;

  const CarDropdownField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.svgIcon,
    this.enabled = true,
    this.isRequired = false,
    required this.dropdownKey,
    this.onTap,
    required this.state,
    required this.itemsExtractor,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return AppTranslation.translate(AppStrings.required);
        }
        return null;
      },
      builder: (fieldState) {
        final items = itemsExtractor(state);
        final isLoading = _isLoadingState(state);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (fieldState.value != controller.text) {
            fieldState.didChange(controller.text);
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label: label, isRequired: isRequired),
            const SizedBox(height: AppTheme.spacingSm),
            DropdownContainer(
              widgetKey: dropdownKey,
              enabled: enabled,
              hasError: fieldState.hasError,
              isLoading: isLoading,
              svgIcon: svgIcon,
              displayText: controller.text.isEmpty ? hint : controller.text,
              isEmpty: controller.text.isEmpty,
              onTap: (!enabled || isLoading || items.isEmpty)
                  ? null
                  : () {
                onTap?.call();
                showDropdownMenu(
                  context: context,
                  title: label,
                  items: items,
                  controller: controller,
                  fieldState: fieldState,
                  anchorKey: dropdownKey,
                );
              },
            ),
            if (fieldState.hasError) FieldError(text: fieldState.errorText!),
          ],
        );
      },
    );
  }

  bool _isLoadingState(dynamic state) {
    return state is GetEngineTypeListLoading ||
        state is GetBodyTypeListLoading ||
        state is GetTransmissionListLoading ||
        state is GetColorListLoading ||
        state is GetYearListLoading;
  }
}