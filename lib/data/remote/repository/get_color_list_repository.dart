import '../contractor/get_color_list_contractor.dart';
import '../models/remote/get_color_list_response.dart';
import '../services/remote/get_color_list_service.dart';

class GetColorListRepository implements GetColorListContractor {
  GetColorListRepository(this._service);

  final GetColorListService _service;

  @override
  Future<List<GetColorListResponse>> getColorList() {
    return _service.getColorList();
  }
}