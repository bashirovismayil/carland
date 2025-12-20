import '../models/remote/get_car_services_response.dart';

abstract class GetCarServicesContractor {
  Future<List<GetCarServicesResponse>> getCarServices(int carId);
}