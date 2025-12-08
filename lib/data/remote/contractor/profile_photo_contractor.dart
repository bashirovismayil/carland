import 'dart:io';
import 'dart:typed_data';
import '../models/remote/upload_profile_photo_response.dart';

abstract class ProfilePhotoContractor {
  Future<UploadProfilePhotoResponse> uploadProfilePhoto(File imageFile);
  Future<Uint8List> getProfilePhoto();
}
