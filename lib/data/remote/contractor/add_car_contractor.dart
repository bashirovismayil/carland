import '../models/remote/add_car_response.dart';

abstract class AddCarContractor {
  Future<AddCarResponse> addCar({
    required String vin,
    required String plateNumber,
    required String brand,
    required String model,
    required int modelYear,
    required String engineType,
    required int engineVolume,
    required String transmissionType,
    required String bodyType,
    int? colorId,
    required int mileage,
    List<String>? vinProvidedFields,
  });
}