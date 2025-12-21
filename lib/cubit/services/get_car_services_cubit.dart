import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_car_services_contractor.dart';
import '../../../utils/di/locator.dart';
import '../../data/remote/models/remote/get_car_services_response.dart';
import 'get_car_services_state.dart';

class GetCarServicesCubit extends Cubit<GetCarServicesState> {
  GetCarServicesCubit() : super(GetCarServicesInitial()) {
    _servicesRepo = locator<GetCarServicesContractor>();
  }

  late final GetCarServicesContractor _servicesRepo;

  Future<void> getCarServices(int carId) async {
    try {
      emit(GetCarServicesLoading());

      final GetCarServicesResponse servicesData =
      await _servicesRepo.getCarServices(carId);

      log("Get Car Services Success: ${servicesData.responseList.length} services found for carId: $carId");
      emit(GetCarServicesSuccess(servicesData));
    } catch (e) {
      emit(GetCarServicesError(e.toString()));
      log("Get Car Services Error: $e");
    }
  }
}