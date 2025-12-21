import '../contractor/delete_car_contractor.dart';
import '../models/remote/delete_car_response.dart';
import '../services/remote/delete_car_service.dart';

class DeleteCarRepository implements DeleteCarContractor {
  DeleteCarRepository(this._service);

  final DeleteCarService _service;

  @override
  Future<DeleteCarResponse> deleteCar({required int carId}) {
    return _service.deleteCar(carId: carId);
  }
}