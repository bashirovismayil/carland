import '../contractor/get_year_list_contractor.dart';
import '../models/remote/get_year_list_response.dart';
import '../services/remote/get_year_list_service.dart';

class GetYearListRepository implements GetYearListContractor {
  GetYearListRepository(this._service);

  final GetYearListService _service;

  @override
  Future<List<GetYearListResponse>> getYearList() {
    return _service.getYearList();
  }
}