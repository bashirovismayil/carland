import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_record_contractor.dart';
import '../../../data/remote/models/remote/GetCarRecordsResponse.dart';
import '../../../utils/di/locator.dart';
import 'get_car_records_state.dart';

class GetCarRecordsCubit extends Cubit<GetCarRecordsState> {
  GetCarRecordsCubit() : super(GetCarRecordsInitial()) {
    _recordsRepo = locator<GetCarRecordsContractor>();
  }

  late final GetCarRecordsContractor _recordsRepo;

  Future<void> getCarRecords(String carId) async {
    try {
      emit(GetCarRecordsLoading());

      final List<GetCarRecordsResponse> records =
      await _recordsRepo.getCarRecords(carId);

      log("Get Car Records Success: ${records.length} records found");
      emit(GetCarRecordsSuccess(records));
    } catch (e) {
      emit(GetCarRecordsError(e.toString()));
      log("Get Car Records Error: $e");
    }
  }

  void reset() {
    emit(GetCarRecordsInitial());
  }
}