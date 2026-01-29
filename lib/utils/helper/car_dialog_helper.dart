import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../cubit/services/get_services/get_car_services_cubit.dart';
import '../../../../cubit/services/get_services/get_car_services_state.dart';
import '../../../../data/remote/models/remote/get_car_list_response.dart';
import '../../presentation/car/details/edit_car_details_page.dart';
import '../../presentation/car/services/widgets/update_mileage_dialog.dart';

class CarDialogHelper {
  static Future<Map<String, dynamic>?> showUpdateMileageDialog(
    BuildContext context,
    GetCarListResponse car,
  ) async {
    final currentState = context.read<GetCarServicesCubit>().state;
    String? vin;

    if (currentState is GetCarServicesSuccess) {
      vin = currentState.servicesData.vin;
    }

    if (vin == null || vin.isEmpty) {
      _showErrorSnackbar(context, AppStrings.vinNotFound);
      return null;
    }

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateMileageDialog(
        vin: vin!,
        currentMileage: car.mileage,
      ),
    );
  }

  static Future<Map<String, dynamic>?> showEditCarDetailsPage(
    BuildContext context,
    GetCarListResponse car,
    List<GetCarListResponse> carList,
  ) async {
    final currentState = context.read<GetCarServicesCubit>().state;
    String? vin;
    int? carId;

    if (currentState is GetCarServicesSuccess) {
      vin = currentState.servicesData.vin;
      carId = currentState.servicesData.carId;
    }

    if (vin == null || vin.isEmpty || carId == null) {
      _showErrorSnackbar(context, AppStrings.carDataNotFound);
      return null;
    }

    final currentCar = carList.firstWhere(
      (c) => c.carId == carId,
      orElse: () => car,
    );

    return Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(
        builder: (context) => EditCarDetailsPage(
          carId: carId!,
          vin: vin!,
          initialPlateNumber: currentCar.plateNumber,
          initialColor: currentCar.color,
          initialMileage: currentCar.mileage,
          initialModelYear: currentCar.modelYear,
          initialEngineType: currentCar.engineType,
          initialEngineVolume: currentCar.engineVolume,
          initialTransmissionType: currentCar.transmissionType,
          initialBodyType: currentCar.bodyType,
          vinProvidedFields: currentCar.vinProvidedFields,
          brand: currentCar.brand,
          model: currentCar.model,
        ),
      ),
    );
  }

  static void _showErrorSnackbar(BuildContext context, String messageKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslation.translate(messageKey)),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
