import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/execute_car_service_contractor.dart';
import '../../../utils/di/locator.dart';
import 'execute_car_service_state.dart';

class ExecuteCarServiceCubit extends Cubit<ExecuteCarServiceState> {
  ExecuteCarServiceCubit() : super(ExecuteCarServiceInitial()) {
    _executeRepo = locator<ExecuteCarServiceContractor>();
  }

  late final ExecuteCarServiceContractor _executeRepo;

  Future<void> executeCarService(int carId) async {
    try {
      emit(ExecuteCarServiceLoading());

      final String message = await _executeRepo.executeCarService(carId);

      log("Execute Car Service Success for carId: $carId - Message: $message");
      emit(ExecuteCarServiceSuccess(message));
    } catch (e) {
      emit(ExecuteCarServiceError(e.toString()));
      log("Execute Car Service Error for carId $carId: $e");
    }
  }
}