import '../models/remote/get_color_list_response.dart';

abstract class GetColorListContractor {
  Future<List<GetColorListResponse>> getColorList();
}