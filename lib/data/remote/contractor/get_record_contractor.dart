import '../models/remote/GetCarRecordsResponse.dart';

abstract class GetCarRecordsContractor {
  Future<List<GetCarRecordsResponse>> getCarRecords(String carId);
}