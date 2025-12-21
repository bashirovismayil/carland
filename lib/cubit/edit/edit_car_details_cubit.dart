import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/edit_car_details_contractor.dart';
import '../../../utils/di/locator.dart';
import '../../data/remote/models/remote/edit_car_details_response.dart';
import 'edit_car_details_state.dart';

class EditCarDetailsCubit extends Cubit<EditCarDetailsState> {
  EditCarDetailsCubit() : super(EditCarDetailsInitial()) {
    _detailsRepo = locator<EditCarDetailsContractor>();
  }

  late final EditCarDetailsContractor _detailsRepo;

  Future<void> editCarDetails({
    required int carId,
    required String vin,
    required String plateNumber,
    required String color,
    required int mileage,
    required int modelYear,
    required String engineType,
    required int engineVolume,
    required String transmissionType,
    required String bodyType,
  }) async {
    try {
      emit(EditCarDetailsLoading());

      final EditCarDetailsResponse response = await _detailsRepo.editCarDetails(
        carId: carId,
        vin: vin,
        plateNumber: plateNumber,
        color: color,
        mileage: mileage,
        modelYear: modelYear,
        engineType: engineType,
        engineVolume: engineVolume,
        transmissionType: transmissionType,
        bodyType: bodyType,
      );

      log("Edit Car Details Success: ${response.toJson()}");
      emit(EditCarDetailsSuccess(response));
    } catch (e) {
      emit(EditCarDetailsError(e.toString()));
      log("Edit Car Details Error: $e");
    }
  }
}