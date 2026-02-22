import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../cubit/add/car/add_car_cubit.dart';
import '../../../../cubit/add/car/add_car_state.dart';
import '../../../../cubit/mileage/update/update_car_mileage_cubit.dart';
import '../../../../cubit/mileage/update/update_milage_state.dart';
import '../../../../cubit/photo/car/upload_car_photo_cubit.dart';
import '../../../../cubit/photo/car/upload_car_photo_state.dart';
import '../../../../data/remote/models/local/car_form_data.dart';
import '../maintenance_history_page.dart';

class CarDetailsBlocListeners extends StatelessWidget {
  final CarFormControllers controllers;
  final Widget child;

  const CarDetailsBlocListeners({
    super.key,
    required this.controllers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddCarCubit, AddCarState>(
          listener: (ctx, state) => _onAddCar(ctx, state),
        ),
        BlocListener<UploadCarPhotoCubit, UploadCarPhotoState>(
          listener: (ctx, state) => _onUploadPhoto(ctx, state),
        ),
        BlocListener<UpdateCarMileageCubit, UpdateCarMileageState>(
          listener: (ctx, state) => _onUpdateMileage(ctx, state),
        ),
      ],
      child: child,
    );
  }

  void _onAddCar(BuildContext context, AddCarState state) {
    if (state is AddCarSuccess) {
      final carId = state.response.carId;
      if (carId == null) {
        _fail(context, AppTranslation.translate(AppStrings.failedToAddCar));
        return;
      }

      final carIdStr = carId.toString();
      final modelYear = int.tryParse(controllers.year.text.trim());

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MaintenanceHistoryPage(
          carId: carIdStr,
          carModelYear: modelYear,
          isInvisible: true,
        ),
      ));

      if (controllers.selectedImage.value != null) {
        context.read<UploadCarPhotoCubit>().uploadCarPhoto(
          carId: carIdStr,
          imageFile: controllers.selectedImage.value!,
        );
      } else {
        _updateMileage(context);
      }
    } else if (state is AddCarError) {
      _fail(context,
          '${AppTranslation.translate(AppStrings.failedToAddCar)}: ${state.message}');
    }
  }

  void _onUploadPhoto(BuildContext context, UploadCarPhotoState state) {
    if (state is UploadCarPhotoSuccess) {
      _updateMileage(context);
    } else if (state is UploadCarPhotoError) {
      controllers.isSubmitting.value = false;
      _showError(context,
          '${AppTranslation.translate(AppStrings.errorOccurred)}: ${state.message}');
      _updateMileage(context);
    }
  }

  void _onUpdateMileage(BuildContext context, UpdateCarMileageState state) {
    controllers.isSubmitting.value = false;
    if (state is UpdateCarMileageError) {
      _showError(context,
          '${AppTranslation.translate(AppStrings.failedToUpdateMileage)}: ${state.message}');
    }
  }

  void _updateMileage(BuildContext context) {
    context.read<UpdateCarMileageCubit>().updateCarMileage(
      vin: controllers.vin.text.trim(),
      mileage: int.tryParse(controllers.mileage.text.trim()) ?? 0,
    );
  }

  void _fail(BuildContext context, String message) {
    controllers.isSubmitting.value = false;
    _showError(context, message);
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}