import '../contractor/get_car_list_contractor.dart';
import '../models/remote/get_car_list_response.dart';
import '../services/remote/get_car_list_service.dart';

class GetCarListRepository implements GetCarListContractor {
  GetCarListRepository(this._service);

  final GetCarListService _service;

  @override
  Future<List<GetCarListResponse>> getCarList() {
    return _service.getCarList();
  }
}