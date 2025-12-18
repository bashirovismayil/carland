import '../contractor/update_mileage_contractor.dart';
import '../models/remote/update_car_mileage_response.dart';
import '../services/remote/update_car_mileage_service.dart';

class UpdateCarMileageRepository implements UpdateCarMileageContractor {
  UpdateCarMileageRepository(this._service);
  final UpdateCarMileageService _service;

  @override
  Future<UpdateCarMileageResponse> updateCarMileage({
    required String vin,
    required int mileage,
  }) {
    return _service.updateCarMileage(vin: vin, mileage: mileage);
  }
}