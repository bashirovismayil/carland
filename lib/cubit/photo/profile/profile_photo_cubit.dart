import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/profile_photo_contractor.dart';
import '../../../utils/di/locator.dart';
import 'profile_photo_state.dart';

class ProfilePhotoCubit extends Cubit<ProfilePhotoState> {
  ProfilePhotoCubit() : super(ProfilePhotoInitial()) {
    _profilePhotoRepo = locator<ProfilePhotoContractor>();
  }

  late final ProfilePhotoContractor _profilePhotoRepo;

  Future<void> uploadProfilePhoto(File imageFile) async {
    try {
      emit(ProfilePhotoUploading());
      final response = await _profilePhotoRepo.uploadProfilePhoto(imageFile);
      emit(ProfilePhotoUploadSuccess(response));
    } catch (e, stack) {
      log('[ProfilePhotoCubit] Upload Error: $e\n$stack');
      emit(ProfilePhotoUploadError(e.toString()));
    }
  }

  Future<void> getProfilePhoto() async {
    try {
      emit(ProfilePhotoLoading());
      final imageData = await _profilePhotoRepo.getProfilePhoto();
      emit(ProfilePhotoLoaded(imageData));
    } catch (e, stack) {
      log('[ProfilePhotoCubit] Get Error: $e\n$stack');
      emit(ProfilePhotoLoadError(e.toString()));
    }
  }
}