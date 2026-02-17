import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../cubit/car/brand/get_car_brand_list_cubit.dart';
import '../../../../../cubit/car/brand/get_car_brand_list_state.dart';
import '../../../../../cubit/car/brand/model/get_car_model_cubit.dart';
import '../../../../../cubit/car/brand/model/get_car_model_list_state.dart';
import '../../../../../data/remote/models/remote/check_vin_response.dart';
import '../../../../../utils/helper/capital_case_formatter.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../data/remote/models/local/car_form_data.dart';
import 'car_text_field.dart';
import 'model_autocomplete.dart';
import 'model_dropdown_field.dart';

class ModelField extends StatelessWidget {
  final CarFormScenario scenario;
  final CheckVinResponse carData;
  final TextEditingController modelController;
  final TextEditingController makeController;
  final GlobalKey modelDropdownKey;
  final VoidCallback unfocusAll;

  const ModelField({
    super.key,
    required this.scenario,
    required this.carData,
    required this.modelController,
    required this.makeController,
    required this.modelDropdownKey,
    required this.unfocusAll,
  });

  @override
  Widget build(BuildContext context) {
    switch (scenario.scenario) {
      case BrandModelScenario.bothFromVin:
        return _buildDisabledTextField();
      case BrandModelScenario.bothMissing:
        return ModelDropdownField(
          modelController: modelController,
          makeController: makeController,
          modelDropdownKey: modelDropdownKey,
          unfocusAll: unfocusAll,
        );
      case BrandModelScenario.brandOnlyFromVin:
        return _ScenarioCModelField(
          carData: carData,
          modelController: modelController,
        );
    }
  }

  Widget _buildDisabledTextField() {
    return CarTextField(
      controller: modelController,
      label: AppTranslation.translate(AppStrings.model),
      hint: AppTranslation.translate(AppStrings.modelHint),
      svgIcon: 'assets/svg/car_model_icon.svg',
      enabled: false,
      isRequired: true,
      inputFormatters: [CapitalCaseFormatter()],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppTranslation.translate(AppStrings.required);
        }
        return null;
      },
    );
  }
}

/// Senaryo C: Brand VIN'den geldi, model yok.
/// BrandId resolve edilir → başarılıysa Autocomplete, değilse fallback TextField.
class _ScenarioCModelField extends StatelessWidget {
  final CheckVinResponse carData;
  final TextEditingController modelController;

  const _ScenarioCModelField({
    required this.carData,
    required this.modelController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCarBrandListCubit, GetCarBrandListState>(
      builder: (context, brandState) {
        final resolvedBrandId = _resolveBrandId(brandState);

        _triggerModelListLoad(context, brandState, resolvedBrandId);

        if (resolvedBrandId == null && brandState is! GetCarBrandListLoading) {
          return _buildFallbackTextField();
        }

        return BlocBuilder<GetCarModelListCubit, GetCarModelListState>(
          builder: (context, modelState) {
            final modelNames = modelState is GetCarModelListSuccess
                ? modelState.models
                .map((m) => m.modelName ?? '')
                .where((n) => n.isNotEmpty)
                .toList()
                : <String>[];

            return ModelAutocompleteField(
              controller: modelController,
              modelNames: modelNames,
              isLoading: modelState is GetCarModelListLoading ||
                  brandState is GetCarBrandListLoading,
            );
          },
        );
      },
    );
  }

  int? _resolveBrandId(GetCarBrandListState brandState) {
    if (brandState is! GetCarBrandListSuccess || carData.brand == null) {
      return null;
    }
    try {
      final matched = brandState.brands.firstWhere(
            (b) => b.brandName?.toLowerCase() == carData.brand!.toLowerCase(),
      );
      return matched.brandId;
    } catch (_) {
      return null;
    }
  }

  void _triggerModelListLoad(
      BuildContext context,
      GetCarBrandListState brandState,
      int? resolvedBrandId,
      ) {
    if (resolvedBrandId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final modelState = context.read<GetCarModelListCubit>().state;

      final loadedBrandId = modelState is GetCarModelListSuccess
          ? (modelState.models.isNotEmpty
          ? modelState.models.first.brandId
          : null)
          : null;

      final shouldReload = modelState is GetCarModelListInitial ||
          (modelState is GetCarModelListSuccess &&
              loadedBrandId != resolvedBrandId);

      if (shouldReload) {
        context.read<GetCarModelListCubit>().getModelList(resolvedBrandId!);
      }
    });
  }

  Widget _buildFallbackTextField() {
    return CarTextField(
      controller: modelController,
      label: AppTranslation.translate(AppStrings.model),
      hint: AppTranslation.translate(AppStrings.modelHint),
      svgIcon: 'assets/svg/car_model_icon.svg',
      enabled: true,
      isRequired: true,
      inputFormatters: [CapitalCaseFormatter()],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppTranslation.translate(AppStrings.required);
        }
        return null;
      },
    );
  }
}