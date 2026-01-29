import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../../cubit/services/get_services/get_car_services_cubit.dart';
import '../../../../cubit/services/get_services/get_car_services_state.dart';
import '../../../../data/remote/models/remote/get_car_list_response.dart';
import 'car_dialog_helper.dart';
import 'controllers/car_services_controller.dart';

mixin CarUpdateHandler<T extends StatefulWidget> on State<T> {
  CarServicesController get controller;

  Future<void> handleUpdateMileage(GetCarListResponse car) async {
    final result = await CarDialogHelper.showUpdateMileageDialog(context, car);
    if (result != null && mounted) {
      _applyMileageUpdate(result);
    }
  }

  void _applyMileageUpdate(Map<String, dynamic> result) {
    final state = context.read<GetCarServicesCubit>().state;
    if (state is GetCarServicesSuccess && result['mileage'] != null) {
      controller.updateCarInList(
        state.servicesData.carId!,
        mileage: result['mileage'] as int,
      );
    }
    _refreshAll();
  }

  Future<void> handleUpdateDetails(GetCarListResponse car) async {
    final result = await CarDialogHelper.showEditCarDetailsPage(
      context,
      car,
      controller.carList,
    );
    if (result != null && mounted) {
      _applyDetailsUpdate(result);
    }
  }

  void _applyDetailsUpdate(Map<String, dynamic> result) {
    final state = context.read<GetCarServicesCubit>().state;
    if (state is GetCarServicesSuccess) {
      final carId = state.servicesData.carId!;
      controller.updateCarInList(
        carId,
        plateNumber: result['plateNumber'] as String?,
        modelYear: result['modelYear'] as int?,
        engineType: result['engineType'] as String?,
        engineVolume: result['engineVolume'] as int?,
        bodyType: result['bodyType'] as String?,
      );
      if (result['photoUpdated'] == true) {
        controller.invalidatePhotoCache(carId);
      }
    }
    _refreshAll();
  }

  void _refreshAll() {
    controller.refreshCurrentCarServices();
    context.read<GetCarListCubit>().getCarList();
    setState(() {});
  }
}
