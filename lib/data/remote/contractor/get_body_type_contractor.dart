import 'package:carcat/data/remote/models/remote/get_body_type_response.dart';

abstract class GetBodyTypeContractor {
  Future<List<GetBodyTypeListResponse>> getBodyTypeList();
}