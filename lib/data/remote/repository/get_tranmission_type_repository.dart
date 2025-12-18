import '../contractor/get_transmission_type_contractor.dart';
import '../models/remote/get_transmission_type_response.dart';
import '../services/remote/get_transmission_type_service.dart';

class GetTransmissionTypeListRepository implements GetTransmissionTypeContractor {
  GetTransmissionTypeListRepository(this._service);

  final GetTransmissionTypeListService _service;

  @override
  Future<List<GetTransmissionTypeListResponse>> getTransmissionTypeList() {
    return _service.getTransmissionTypeList();
  }
}