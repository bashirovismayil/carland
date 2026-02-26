import 'package:carcat/presentation/car/details/car_details_widgets/shared_field_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../cubit/car/brand/get_car_brand_list_cubit.dart';
import '../../../../../cubit/car/brand/get_car_brand_list_state.dart';
import '../../../../../cubit/car/brand/model/get_car_model_cubit.dart';
import 'dropdown_menu_helper.dart';

class MakeBrandDropdown extends StatelessWidget {
  final TextEditingController makeController;
  final TextEditingController modelController;
  final GlobalKey brandKey;
  final VoidCallback unfocusAll;

  const MakeBrandDropdown({
    super.key,
    required this.makeController,
    required this.modelController,
    required this.brandKey,
    required this.unfocusAll,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCarBrandListCubit, GetCarBrandListState>(
      builder: (context, state) {
        final brands = state is GetCarBrandListSuccess ? state.brands : [];
        final isLoading = state is GetCarBrandListLoading;
        final items = brands
            .map((b) => b.brandName as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return FormField<String>(
          initialValue: makeController.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppTranslation.translate(AppStrings.required);
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (fieldState) {
            _syncFieldState(fieldState);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel(
                  label: AppTranslation.translate(AppStrings.make),
                  isRequired: true,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                DropdownContainer(
                  widgetKey: brandKey,
                  enabled: true,
                  hasError: fieldState.hasError,
                  isLoading: isLoading,
                  svgIcon: 'assets/svg/car_make_icon.svg',
                  displayText: makeController.text.isEmpty
                      ? AppTranslation.translate(AppStrings.makeHint)
                      : makeController.text,
                  isEmpty: makeController.text.isEmpty,
                  onTap: (isLoading || items.isEmpty)
                      ? null
                      : () => _onDropdownTap(context, state, items, fieldState),
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
      if (fieldState.value != makeController.text) {
        fieldState.didChange(makeController.text);
      }
    });
  }

  void _onDropdownTap(
      BuildContext context,
      GetCarBrandListState state,
      List<String> items,
      FormFieldState<String> fieldState,
      ) {
    unfocusAll();
    showDropdownMenu(
      context: context,
      title: AppTranslation.translate(AppStrings.make),
      items: items,
      controller: makeController,
      fieldState: fieldState,
      anchorKey: brandKey,
      onSelected: (selectedBrandName) {
        _onBrandSelected(context, state, selectedBrandName);
        fieldState.didChange(makeController.text);
      },
    );
  }

  void _onBrandSelected(
      BuildContext context,
      GetCarBrandListState state,
      String selectedBrandName,
      ) {
    modelController.clear();
    if (state is GetCarBrandListSuccess) {
      try {
        final matched = state.brands.firstWhere(
              (b) => b.brandName == selectedBrandName,
        );
        if (matched.brandId != null) {
          context.read<GetCarModelListCubit>().getModelList(matched.brandId!);
        }
      } catch (_) {}
    }
  }
}