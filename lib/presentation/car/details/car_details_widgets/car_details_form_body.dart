import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../core/mixins/plate_number_mixin.dart';
import '../../../../cubit/body/type/get_body_type_cubit.dart';
import '../../../../cubit/body/type/get_body_type_state.dart';
import '../../../../cubit/engine/type/get_engine_type_cubit.dart';
import '../../../../cubit/engine/type/get_engine_type_state.dart';
import '../../../../cubit/year/list/get_year_list_cubit.dart';
import '../../../../cubit/year/list/get_year_list_state.dart';
import '../../../../data/remote/models/local/car_form_data.dart';
import '../../../../data/remote/models/remote/check_vin_response.dart';
import '../../photo/car_photo_upload_widget.dart';
import '../hooks/dropdown_keys.dart';
import 'car_details_section_title.dart';
import 'car_dropdown_field.dart';
import 'car_text_field.dart';
import 'make_field.dart';
import 'model_field.dart';

class CarDetailsFormBody extends StatelessWidget {
  final CarFormControllers controllers;
  final CarFormScenario scenario;
  final CheckVinResponse carData;
  final DropdownKeys dropdownKeys;
  final VoidCallback unfocusAll;

  const CarDetailsFormBody({
    super.key,
    required this.controllers,
    required this.scenario,
    required this.carData,
    required this.dropdownKeys,
    required this.unfocusAll,
  });

  @override
  Widget build(BuildContext context) {
    final plateFormatter = AzerbaijanPlateNumberFormatter();

    return Form(
      key: controllers.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingSm),
            const CarDetailsSectionTitle(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildVinField(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildPlateField(plateFormatter),
            const SizedBox(height: AppTheme.spacingMd),
            _buildMakeField(context),
            const SizedBox(height: AppTheme.spacingMd),
            _buildModelField(context),
            const SizedBox(height: AppTheme.spacingMd),
            _buildEngineVolumeField(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildBodyTypeDropdown(context),
            const SizedBox(height: AppTheme.spacingMd),
            _buildEngineTypeDropdown(context),
            const SizedBox(height: AppTheme.spacingMd),
            _buildYearDropdown(context),
            const SizedBox(height: AppTheme.spacingMd),
            _buildMileageField(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildPhotoUpload(),
          ],
        ),
      ),
    );
  }

  Widget _buildVinField() {
    return CarTextField(
      controller: controllers.vin,
      label: AppTranslation.translate(AppStrings.vinText),
      hint: AppTranslation.translate(AppStrings.vinPlaceholder),
      svgIcon: 'assets/svg/barcode_transparent.svg',
      enabled: false,
      isRequired: false,
    );
  }

  Widget _buildPlateField(AzerbaijanPlateNumberFormatter formatter) {
    return CarTextField(
      controller: controllers.plate,
      focusNode: controllers.plateFocus,
      label: AppTranslation.translate(AppStrings.plateNumber),
      hint: formatter.hint,
      svgIcon: 'assets/svg/plate_number_icon.svg',
      enabled: true,
      isRequired: true,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [formatter],
      maxLength: AzerbaijanPlateNumberFormatter.maxLength,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppTranslation.translate(AppStrings.plateNumberRequired);
        }
        if (value.isNotEmpty &&
            !AzerbaijanPlateNumberFormatter.isValid(value)) {
          return AppTranslation.translate(AppStrings.invalidPlateNumberFormat);
        }
        return null;
      },
    );
  }

  Widget _buildMakeField(BuildContext context) {
    return MakeField(
      scenario: scenario,
      makeController: controllers.make,
      modelController: controllers.model,
      brandKey: dropdownKeys.brand,
      unfocusAll: unfocusAll,
    );
  }

  Widget _buildModelField(BuildContext context) {
    return ModelField(
      scenario: scenario,
      carData: carData,
      modelController: controllers.model,
      makeController: controllers.make,
      modelDropdownKey: dropdownKeys.modelDropdown,
      unfocusAll: unfocusAll,
    );
  }

  Widget _buildEngineVolumeField() {
    return CarTextField(
      controller: controllers.engine,
      focusNode: controllers.engineFocus,
      maxLength: 4,
      label: AppTranslation.translate(AppStrings.engineVolume),
      hint: AppTranslation.translate(AppStrings.engineVolumeHint),
      svgIcon: 'assets/svg/car_engine_icon.svg',
      enabled: !scenario.hasEngineVolume,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      isRequired: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppTranslation.translate(AppStrings.required);
        }
        return null;
      },
    );
  }

  Widget _buildBodyTypeDropdown(BuildContext context) {
    return CarDropdownField(
      controller: controllers.bodyType,
      label: AppTranslation.translate(AppStrings.bodyType),
      hint: AppTranslation.translate(AppStrings.selectBodyType),
      svgIcon: 'assets/svg/car_body_type_icon.svg',
      state: context.watch<GetBodyTypeListCubit>().state,
      itemsExtractor: (state) {
        if (state is GetBodyTypeListSuccess) {
          return state.bodyTypes.map((e) => e.bodyType).toList();
        }
        return [];
      },
      enabled: !scenario.hasBodyType,
      isRequired: true,
      dropdownKey: dropdownKeys.bodyType,
      onTap: unfocusAll,
    );
  }

  Widget _buildEngineTypeDropdown(BuildContext context) {
    return CarDropdownField(
      controller: controllers.engineType,
      label: AppTranslation.translate(AppStrings.engineType),
      hint: AppTranslation.translate(AppStrings.selectType),
      svgIcon: 'assets/svg/car_engine_type_icon.svg',
      state: context.watch<GetEngineTypeListCubit>().state,
      itemsExtractor: (state) {
        if (state is GetEngineTypeListSuccess) {
          return state.engineTypes.map((e) => e.engineType).toList();
        }
        return [];
      },
      isRequired: true,
      dropdownKey: dropdownKeys.engineType,
      onTap: unfocusAll,
    );
  }

  Widget _buildYearDropdown(BuildContext context) {
    return CarDropdownField(
      controller: controllers.year,
      label: AppTranslation.translate(AppStrings.year),
      hint: AppTranslation.translate(AppStrings.selectYear),
      svgIcon: 'assets/svg/calendar_nav_icon.svg',
      state: context.watch<GetYearListCubit>().state,
      itemsExtractor: (state) {
        if (state is GetYearListSuccess) {
          return state.years.map((e) => e.modelYear.toString()).toList();
        }
        return [];
      },
      enabled: !scenario.hasModelYear,
      isRequired: true,
      dropdownKey: dropdownKeys.year,
      onTap: unfocusAll,
    );
  }

  Widget _buildMileageField() {
    return CarTextField(
      controller: controllers.mileage,
      focusNode: controllers.mileageFocus,
      label: AppTranslation.translate(AppStrings.currentMileage),
      hint: AppTranslation.translate(AppStrings.mileageHint),
      svgIcon: 'assets/svg/odometer_icon.svg',
      enabled: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 6,
      isRequired: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppTranslation.translate(AppStrings.mileageRequired);
        }
        return null;
      },
    );
  }

  Widget _buildPhotoUpload() {
    return CarPhotoUploadWidget(
      selectedImage: controllers.selectedImage.value,
      onImageChanged: (file) => controllers.selectedImage.value = file,
      isRequired: false,
      onTap: unfocusAll,
    );
  }
}