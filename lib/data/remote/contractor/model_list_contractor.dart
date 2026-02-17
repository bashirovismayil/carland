import '../models/remote/get_model_list_response.dart';

abstract class GetCarModelListContractor {
  Future<List<ModelListResponse>> getModelList(int brandId);
}