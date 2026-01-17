import '../contractor/add_car_contractor.dart';
import '../models/remote/add_car_response.dart';
import '../services/remote/add_car_service.dart';

class AddCarRepository implements AddCarContractor {
  AddCarRepository(this._service);

  final AddCarService _service;

  @override
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
  }) {
    return _service.addCar(
      vin: vin,
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      modelYear: modelYear,
      engineType: engineType,
      engineVolume: engineVolume,
      transmissionType: transmissionType,
      bodyType: bodyType,
      colorId: colorId,
      mileage: mileage,
      vinProvidedFields: vinProvidedFields,
    );
  }
}