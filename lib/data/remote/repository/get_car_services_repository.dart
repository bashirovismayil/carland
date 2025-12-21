import '../contractor/get_car_services_contractor.dart';
import '../models/remote/get_car_services_response.dart';
import '../services/remote/get_car_services_list_service.dart';

class GetCarServicesRepository implements GetCarServicesContractor {
  GetCarServicesRepository(this._service);

  final GetCarServicesService _service;

  @override
  Future<GetCarServicesResponse> getCarServices(int carId) {
    return _service.getCarServices(carId);
  }
}