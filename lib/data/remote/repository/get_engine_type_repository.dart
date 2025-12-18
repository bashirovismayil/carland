import '../contractor/get_engine_type_contractor.dart';
import '../models/remote/get_engine_type_response.dart';
import '../services/remote/get_engine_type_list_service.dart';

class GetEngineTypeListRepository implements GetEngineTypeListContractor {
  GetEngineTypeListRepository(this._service);
  final GetEngineTypeListService _service;

  @override
  Future<List<GetEngineTypeListResponse>> getEngineTypeList() {
    return _service.getEngineTypeList();
  }
}