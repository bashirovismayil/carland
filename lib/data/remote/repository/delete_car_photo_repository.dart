import '../contractor/delete_car_photo_contractor.dart';
import '../services/remote/delete_car_photo_service.dart';

class DeleteCarPhotoRepository implements DeleteCarPhotoContractor {
  DeleteCarPhotoRepository(this._service);

  final DeleteCarPhotoService _service;

  @override
  Future<bool> deleteCarPhoto(int carId) {
    return _service.deleteCarPhoto(carId);
  }
}