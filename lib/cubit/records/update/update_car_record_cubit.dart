import 'dart:developer';
import 'package:carcat/cubit/records/update/update_car_record_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/update_car_records_contractor.dart';
import '../../../utils/di/locator.dart';

class UpdateCarRecordCubit extends Cubit<UpdateCarRecordState> {
  UpdateCarRecordCubit() : super(UpdateCarRecordInitial()) {
    _recordRepo = locator<UpdateCarRecordContractor>();
  }

  late final UpdateCarRecordContractor _recordRepo;

  Future<void> updateCarRecord({
    required int carId,
    required int recordId,
    required String doneDate,
    required int doneKm,
  }) async {
    try {
      emit(UpdateCarRecordLoading(recordId));

      final response = await _recordRepo.updateCarRecord(
        carId: carId,
        recordId: recordId,
        doneDate: doneDate,
        doneKm: doneKm,
      );

      log("Update Car Record Success: Record ID $recordId updated");
      emit(UpdateCarRecordSuccess(recordId, response));
    } catch (e) {
      emit(UpdateCarRecordError(recordId, e.toString()));
      log("Update Car Record Error: $e");
    }
  }

  void reset() {
    emit(UpdateCarRecordInitial());
  }
}