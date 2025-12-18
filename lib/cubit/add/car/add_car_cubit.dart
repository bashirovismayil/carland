import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/add_car_contractor.dart';
import '../../../data/remote/models/remote/add_car_response.dart';
import '../../../utils/di/locator.dart';
import 'add_car_state.dart';

class AddCarCubit extends Cubit<AddCarState> {
  AddCarCubit() : super(AddCarInitial()) {
    _carRepo = locator<AddCarContractor>();
  }

  late final AddCarContractor _carRepo;

  Future<void> addCar({
    required String vin,
    required String plateNumber,
    required String brand,
    required String model,
    required int modelYear,
    required String engineType,
    required int engineVolume,
    required String transmissionType,
    required String bodyType,
    required String color,
    required int mileage,
  }) async {
    try {
      emit(AddCarLoading());

      final AddCarResponse response = await _carRepo.addCar(
        vin: vin,
        plateNumber: plateNumber,
        brand: brand,
        model: model,
        modelYear: modelYear,
        engineType: engineType,
        engineVolume: engineVolume,
        transmissionType: transmissionType,
        bodyType: bodyType,
        color: color,
        mileage: mileage,
      );

      log("Add Car Success: ${response.toJson()}");
      emit(AddCarSuccess(response));
    } catch (e) {
      emit(AddCarError(e.toString()));
      log("Add Car Error: $e");
    }
  }
}