import '../contractor/edit_service_details_contractor.dart';
import '../models/remote/edit_services_details_response.dart';
import '../services/remote/edit_services_details_service.dart';

class EditCarServicesRepository implements EditCarServicesContractor {
  EditCarServicesRepository(this._service);

  final EditCarServicesService _service;

  @override
  Future<EditCarServicesResponse> editCarServices({
    required int carId,
    required int percentageId,
    required String lastServiceDate,
    required int lastServiceKm,
    String? nextServiceDate,
    int? nextServiceKm,
  }) {
    return _service.editCarServices(
      carId: carId,
      percentageId: percentageId,
      lastServiceDate: lastServiceDate,
      lastServiceKm: lastServiceKm,
      nextServiceDate: nextServiceDate,
      nextServiceKm: nextServiceKm,
    );
  }
}