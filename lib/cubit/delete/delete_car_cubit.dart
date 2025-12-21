import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/remote/contractor/delete_car_contractor.dart';
import '../../data/remote/models/remote/delete_car_response.dart';
import '../../utils/di/locator.dart';
import 'delete_car_state.dart';

class DeleteCarCubit extends Cubit<DeleteCarState> {
  DeleteCarCubit() : super(DeleteCarInitial()) {
    _deleteCarRepo = locator<DeleteCarContractor>();
  }

  late final DeleteCarContractor _deleteCarRepo;

  Future<void> deleteCar({required int carId}) async {
    try {
      emit(DeleteCarLoading());

      final DeleteCarResponse response =
      await _deleteCarRepo.deleteCar(carId: carId);

      log("Delete Car Success: ${response.toJson()}");
      emit(DeleteCarSuccess(response));
    } catch (e) {
      emit(DeleteCarError(e.toString()));
      log("Delete Car Error: $e");
    }
  }
}