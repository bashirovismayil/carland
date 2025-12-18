import 'dart:typed_data';
import '../contractor/get_car_photo_contractor.dart';
import '../services/remote/get_car_photo_service.dart';

class GetCarPhotoRepository implements GetCarPhotoContractor {
  GetCarPhotoRepository(this._service);

  final GetCarPhotoService _service;

  @override
  Future<Uint8List> getCarPhoto(int carId) {
    return _service.getCarPhoto(carId);
  }
}