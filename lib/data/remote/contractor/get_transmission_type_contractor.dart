import 'package:carcat/data/remote/models/remote/get_transmission_type_response.dart';

abstract class GetTransmissionTypeContractor {
  Future<List<GetTransmissionTypeListResponse>> getTransmissionTypeList();
}