import '../models/remote/edit_car_details_response.dart';

abstract class EditCarDetailsContractor {
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
  });
}