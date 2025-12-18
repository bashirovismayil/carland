import 'dart:io';
import '../models/remote/upload_car_photo_response.dart';

abstract class UploadCarPhotoContractor {
  Future<UploadCarPhotoResponse> uploadCarPhoto({
    required String carId,
    required File imageFile,
  });
}