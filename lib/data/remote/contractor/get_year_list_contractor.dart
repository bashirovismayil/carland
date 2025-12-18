import 'package:carcat/data/remote/models/remote/get_year_list_response.dart';

abstract class GetYearListContractor {
  Future<List<GetYearListResponse>> getYearList();
}