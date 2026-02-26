import 'package:carcat/presentation/car/details/car_details_widgets/shared_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../cubit/car/brand/model/get_car_model_cubit.dart';
import '../../../../../cubit/car/brand/model/get_car_model_list_state.dart';
import 'dropdown_menu_helper.dart';

class ModelDropdownField extends StatelessWidget {
  final TextEditingController modelController;
  final TextEditingController makeController;
  final GlobalKey modelDropdownKey;
  final VoidCallback unfocusAll;

  const ModelDropdownField({
    super.key,
    required this.modelController,
    required this.makeController,
    required this.modelDropdownKey,
    required this.unfocusAll,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: modelController.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppTranslation.translate(AppStrings.required);
        }
        return null;
      },
      builder: (fieldState) {
        _syncFieldState(fieldState);

        return BlocBuilder<GetCarModelListCubit, GetCarModelListState>(
          builder: (context, state) {
            final models = state is GetCarModelListSuccess ? state.models : [];
            final isLoading = state is GetCarModelListLoading;
            final items = models
                .map((m) => m.modelName as String? ?? '')
                .where((name) => name.isNotEmpty)
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

            final isBrandSelected = makeController.text.isNotEmpty;
            final isEnabled = isBrandSelected && !isLoading && items.isNotEmpty;

            final displayText = !isBrandSelected
                ? AppTranslation.translate(AppStrings.chooseTheBrandFirst)
                : (modelController.text.isEmpty
                    ? AppTranslation.translate(AppStrings.modelHint)
                    : modelController.text);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel(
                  label: AppTranslation.translate(AppStrings.model),
                  isRequired: true,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                DropdownContainer(
                  widgetKey: modelDropdownKey,
                  enabled: isEnabled,
                  hasError: fieldState.hasError,
                  isLoading: isLoading,
                  svgIcon: 'assets/svg/car_model_icon.svg',
                  displayText: displayText,
                  isEmpty: !isBrandSelected || modelController.text.isEmpty,
                  onTap: !isEnabled
                      ? null
                      : () {
                          unfocusAll();
                          showDropdownMenu(
                            context: context,
                            title: AppTranslation.translate(AppStrings.model),
                            items: items,
                            controller: modelController,
                            fieldState: fieldState,
                            anchorKey: modelDropdownKey,
                          );
                        },
                ),
                if (fieldState.hasError)
                  FieldError(text: fieldState.errorText!),
              ],
            );
          },
        );
      },
    );
  }

  void _syncFieldState(FormFieldState<String> fieldState) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fieldState.value != modelController.text) {
        fieldState.didChange(modelController.text);
      }
    });
  }
}
