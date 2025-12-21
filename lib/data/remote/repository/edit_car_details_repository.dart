
import '../contractor/edit_car_details_contractor.dart';
import '../models/remote/edit_car_details_response.dart';
import '../services/remote/edit_car_details_service.dart';

class EditCarDetailsRepository implements EditCarDetailsContractor {
  EditCarDetailsRepository(this._service);

  final EditCarDetailsService _service;

  @override
  Future<EditCarDetailsResponse> editCarDetails({
    required int carId,
    required String vin,
    required String plateNumber,
    required String color,
    required int mileage,
    required int modelYear,
    required String engineType,
    required int engineVolume,
    required String transmissionType,
    required String bodyType,
  }) {
    return _service.editCarDetails(
      carId: carId,
      vin: vin,
      plateNumber: plateNumber,
      color: color,
      mileage: mileage,
      modelYear: modelYear,
      engineType: engineType,
      engineVolume: engineVolume,
      transmissionType: transmissionType,
      bodyType: bodyType,
    );
  }
}