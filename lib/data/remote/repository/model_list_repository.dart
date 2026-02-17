import '../contractor/model_list_contractor.dart';
import '../models/remote/get_model_list_response.dart';
import '../services/remote/get_model_list_service.dart';

class GetCarModelListRepository implements GetCarModelListContractor {
  GetCarModelListRepository(this._service);

  final GetCarModelListService _service;

  @override
  Future<List<ModelListResponse>> getModelList(int brandId) {
    return _service.getModelList(brandId);
  }
}