import '../contractor/get_body_type_contractor.dart';
import '../models/remote/get_body_type_response.dart';
import '../services/remote/get_body_type_list_service.dart';

class GetBodyTypeListRepository implements GetBodyTypeContractor {
  GetBodyTypeListRepository(this._service);

  final GetBodyTypeListService _service;

  @override
  Future<List<GetBodyTypeListResponse>> getBodyTypeList() {
    return _service.getBodyTypeList();
  }
}