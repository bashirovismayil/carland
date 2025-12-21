import '../models/remote/edit_services_details_response.dart';

abstract class EditCarServicesContractor {
  Future<EditCarServicesResponse> editCarServices({
    required int carId,
    required int percentageId,
    required String lastServiceDate,
    required int lastServiceKm,
    required String nextServiceDate,
    required int nextServiceKm,
  });
}