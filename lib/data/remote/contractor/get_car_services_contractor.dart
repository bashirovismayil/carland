import '../models/remote/get_car_services_response.dart';

abstract class GetCarServicesContractor {
  Future<GetCarServicesResponse> getCarServices(int carId);
}