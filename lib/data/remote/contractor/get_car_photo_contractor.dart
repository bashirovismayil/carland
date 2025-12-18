import 'dart:typed_data';

abstract class GetCarPhotoContractor {
  Future<Uint8List> getCarPhoto(int carId);
}