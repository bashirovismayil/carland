import '../models/remote/get_engine_type_response.dart';

abstract class GetEngineTypeListContractor {
  Future<List<GetEngineTypeListResponse>> getEngineTypeList();
}