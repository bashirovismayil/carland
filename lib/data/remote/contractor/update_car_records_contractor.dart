import '../models/remote/update_car_records_response.dart';

abstract class UpdateCarRecordContractor {
  Future<UpdateCarRecordResponse> updateCarRecord({
    required int carId,
    required int recordId,
    required String doneDate,
    required int doneKm,
  });
}