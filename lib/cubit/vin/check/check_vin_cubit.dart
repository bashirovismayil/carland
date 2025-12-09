import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/check_vin_contractor.dart';
import '../../../data/remote/models/remote/check_vin_response.dart';
import '../../../utils/di/locator.dart';
import 'check_vin_state.dart';

class CheckVinCubit extends Cubit<CheckVinState> {
  CheckVinCubit() : super(CheckVinInitial()) {
    _vinRepo = locator<CheckVinContractor>();
  }

  late final CheckVinContractor _vinRepo;

  Future<void> checkVin(String vin) async {
    try {
      emit(CheckVinLoading());

      final CheckVinResponse carData = await _vinRepo.checkVin(vin);

      log("Check VIN Success: ${carData.toJson()}");
      emit(CheckVinSuccess(carData));
    } catch (e) {
      emit(CheckVinError(e.toString()));
      log("Check VIN Error: $e");
    }
  }

  void reset() {
    emit(CheckVinInitial());
  }
}