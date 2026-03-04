import '../../../data/remote/models/remote/get_car_services_response.dart';

class ServiceEditHelper {
  static bool needsEdit(ResponseList service) {
    return service.lastServiceKm == 0 && !service.isNeverServiced;
  }
}