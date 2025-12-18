import '../models/remote/update_car_mileage_response.dart';

abstract class UpdateCarMileageContractor {
  Future<UpdateCarMileageResponse> updateCarMileage({
    required String vin,
    required int mileage,
  });
}