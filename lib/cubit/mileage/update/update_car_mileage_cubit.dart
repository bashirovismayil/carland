import 'dart:developer';
import 'package:carcat/cubit/mileage/update/update_milage_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/update_mileage_contractor.dart';
import '../../../data/remote/models/remote/update_car_mileage_response.dart';
import '../../../utils/di/locator.dart';

class UpdateCarMileageCubit extends Cubit<UpdateCarMileageState> {
  UpdateCarMileageCubit() : super(UpdateCarMileageInitial()) {
    _mileageRepo = locator<UpdateCarMileageContractor>();
  }

  late final UpdateCarMileageContractor _mileageRepo;

  Future<void> updateCarMileage({
    required String vin,
    required int mileage,
  }) async {
    try {
      emit(UpdateCarMileageLoading());

      final UpdateCarMileageResponse response =
      await _mileageRepo.updateCarMileage(
        vin: vin,
        mileage: mileage,
      );

      log("Update Car Mileage Success: ${response.toJson()}");
      emit(UpdateCarMileageSuccess(response));
    } catch (e) {
      emit(UpdateCarMileageError(e.toString()));
      log("Update Car Mileage Error: $e");
    }
  }
}