import '../contractor/execute_car_service_contractor.dart';
import '../services/remote/execute_car_service.dart';

class ExecuteCarServiceRepository implements ExecuteCarServiceContractor {
  ExecuteCarServiceRepository(this._service);

  final ExecuteCarServiceService _service;

  @override
  Future<String> executeCarService(int carId) {
    return _service.executeCarService(carId);
  }
}