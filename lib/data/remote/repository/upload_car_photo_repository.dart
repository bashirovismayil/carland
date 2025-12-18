import 'dart:io';
import '../contractor/upload_car_photo_contractor.dart';
import '../models/remote/upload_car_photo_response.dart';
import '../services/remote/upload_car_photo_service.dart';

class UploadCarPhotoRepository implements UploadCarPhotoContractor {
  UploadCarPhotoRepository(this._service);

  final UploadCarPhotoService _service;

  @override
  Future<UploadCarPhotoResponse> uploadCarPhoto({
    required String carId,
    required File imageFile,
  }) {
    return _service.uploadCarPhoto(carId: carId, imageFile: imageFile);
  }
}