import '../contractor/get_record_contractor.dart';
import '../models/remote/GetCarRecordsResponse.dart';
import '../services/remote/get_car_records_service.dart';

class GetCarRecordsRepository implements GetCarRecordsContractor {
  GetCarRecordsRepository(this._service);

  final GetCarRecordsService _service;

  @override
  Future<List<GetCarRecordsResponse>> getCarRecords(String carId) {
    return _service.getCarRecords(carId);
  }
}