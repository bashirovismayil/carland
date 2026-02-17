import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../cubit/add/car/add_car_cubit.dart';
import '../../../../data/remote/models/local/car_form_data.dart';
import '../../../../data/remote/models/remote/check_vin_response.dart';

class CarFormSubmitter {
  final BuildContext context;
  final CarFormControllers controllers;
  final CheckVinResponse carData;

  const CarFormSubmitter({
    required this.context,
    required this.controllers,
    required this.carData,
  });

  void submit() {
    FocusScope.of(context).unfocus();

    if (controllers.isSubmitting.value) return;
    controllers.isSubmitting.value = true;

    if (!_validateForm()) return;
    if (!_validateDropdowns()) return;

    final year = int.tryParse(controllers.year.text.trim());
    final engineVol = int.tryParse(controllers.engine.text.trim());
    final mileage = int.tryParse(controllers.mileage.text.trim());

    if (year == null || engineVol == null || mileage == null) {
      _showError(AppTranslation.translate(AppStrings.invalidNumberFormat));
      return;
    }

    context.read<AddCarCubit>().addCar(
      vin: controllers.vin.text.trim(),
      plateNumber: controllers.plate.text.trim(),
      brand: controllers.make.text.trim(),
      model: controllers.model.text.trim(),
      modelYear: year,
      engineType: controllers.engineType.text.trim(),
      engineVolume: engineVol,
      transmissionType: controllers.transmission.text.trim(),
      bodyType: controllers.bodyType.text.trim(),
      colorId: null,
      mileage: mileage,
      vinProvidedFields: carData.vinProvidedFields,
    );
  }

  bool _validateForm() {
    if (!(controllers.formKey.currentState?.validate() ?? false)) {
      _showError(
        AppTranslation.translate(AppStrings.pleaseFillAllRequiredFields),
      );
      return false;
    }
    return true;
  }

  bool _validateDropdowns() {
    if (controllers.bodyType.text.isEmpty ||
        controllers.engineType.text.isEmpty ||
        controllers.year.text.isEmpty) {
      _showError(
        AppTranslation.translate(AppStrings.pleaseFillAllRequiredFields),
      );
      return false;
    }
    return true;
  }

  void _showError(String message) {
    controllers.isSubmitting.value = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}