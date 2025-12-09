import '../models/remote/check_vin_response.dart';

abstract class CheckVinContractor {
  Future<CheckVinResponse> checkVin(String vin);
}