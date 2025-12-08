import 'dart:io';
import 'dart:typed_data';
import '../contractor/profile_photo_contractor.dart';
import '../services/remote/profile_photo_service.dart';
import '../models/remote/upload_profile_photo_response.dart';

class ProfilePhotoRepository implements ProfilePhotoContractor {
  final ProfilePhotoService _service;

  ProfilePhotoRepository(this._service);

  @override
  Future<UploadProfilePhotoResponse> uploadProfilePhoto(File imageFile) {
    return _service.uploadProfilePhoto(imageFile);
  }

  @override
  Future<Uint8List> getProfilePhoto() {
    return _service.getProfilePhoto();
  }
}