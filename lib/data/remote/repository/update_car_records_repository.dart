import '../contractor/update_car_records_contractor.dart';
import '../models/remote/update_car_records_response.dart';
import '../services/remote/update_car_records_service.dart';

class UpdateCarRecordRepository implements UpdateCarRecordContractor {
  UpdateCarRecordRepository(this._service);

  final UpdateCarRecordService _service;

  @override
  Future<UpdateCarRecordResponse> updateCarRecord({
    required int carId,
    required int recordId,
    required String doneDate,
    required int doneKm,
  }) {
    return _service.updateCarRecord(
      carId: carId,
      recordId: recordId,
      doneDate: doneDate,
      doneKm: doneKm,
    );
  }
}