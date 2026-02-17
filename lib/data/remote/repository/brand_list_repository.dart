import '../contractor/brand_list_contractor.dart';
import '../models/remote/get_brand_list_response.dart';
import '../services/remote/get_brand_list_service.dart';

class GetCarBrandListRepository implements GetCarBrandListContractor {
  GetCarBrandListRepository(this._service);

  final GetCarBrandListService _service;

  @override
  Future<List<BrandListResponse>> getBrandList() {
    return _service.getBrandList();
  }
}