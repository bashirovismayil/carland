import '../models/remote/get_brand_list_response.dart';

abstract class GetCarBrandListContractor {
  Future<List<BrandListResponse>> getBrandList();
}