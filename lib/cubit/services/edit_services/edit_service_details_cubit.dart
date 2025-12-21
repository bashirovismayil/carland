import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/edit_service_details_contractor.dart';
import '../../../data/remote/models/remote/edit_services_details_response.dart';
import '../../../utils/di/locator.dart';
import 'edit_service_details_state.dart';

class EditCarServicesCubit extends Cubit<EditCarServicesState> {
  EditCarServicesCubit() : super(EditCarServicesInitial()) {
    _servicesRepo = locator<EditCarServicesContractor>();
  }

  late final EditCarServicesContractor _servicesRepo;

  Future<void> editCarServices({
    required int carId,
    required int percentageId,
    required String lastServiceDate,
    required int lastServiceKm,
    required String nextServiceDate,
    required int nextServiceKm,
  }) async {
    try {
      emit(EditCarServicesLoading());

      final EditCarServicesResponse response = await _servicesRepo.editCarServices(
        carId: carId,
        percentageId: percentageId,
        lastServiceDate: lastServiceDate,
        lastServiceKm: lastServiceKm,
        nextServiceDate: nextServiceDate,
        nextServiceKm: nextServiceKm,
      );

      log("Edit Car Services Success: ${response.toJson()}");
      emit(EditCarServicesSuccess(response));
    } catch (e) {
      emit(EditCarServicesError(e.toString()));
      log("Edit Car Services Error: $e");
    }
  }
}