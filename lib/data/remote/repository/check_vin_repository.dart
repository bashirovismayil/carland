import '../contractor/check_vin_contractor.dart';
import '../models/remote/check_vin_response.dart';
import '../services/remote/check_vin_service.dart';

class CheckVinRepository implements CheckVinContractor {
  CheckVinRepository(this._service);

  final CheckVinService _service;

  @override
  Future<CheckVinResponse> checkVin(String vin) {
    return _service.checkVin(vin);
  }
}