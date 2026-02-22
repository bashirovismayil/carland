import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/profile_photo_contractor.dart';
import '../../../utils/di/locator.dart';
import 'profile_photo_state.dart';

class ProfilePhotoCubit extends Cubit<ProfilePhotoState> {
  ProfilePhotoCubit() : super(ProfilePhotoInitial()) {
    _profilePhotoRepo = locator<ProfilePhotoContractor>();
    getProfilePhoto();
  }

  late final ProfilePhotoContractor _profilePhotoRepo;
  Uint8List? _cachedImageData;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  bool get _isCacheValid {
    if (_cachedImageData == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
  Uint8List? get cachedImage => _cachedImageData;

  Future<void> uploadProfilePhoto(File imageFile) async {
    try {
      emit(ProfilePhotoUploading());
      final response = await _profilePhotoRepo.uploadProfilePhoto(imageFile);
      _cachedImageData = null;
      _lastFetchTime = null;

      emit(ProfilePhotoUploadSuccess(response));
      await getProfilePhoto(forceRefresh: true);
    } catch (e, stack) {
      log('[ProfilePhotoCubit] Upload Error: $e\n$stack');
      emit(ProfilePhotoUploadError(e.toString()));
    }
  }

  Future<void> getProfilePhoto({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _cachedImageData != null) {
      emit(ProfilePhotoLoaded(_cachedImageData!));
      return;
    }

    try {
      emit(ProfilePhotoLoading());
      final imageData = await _profilePhotoRepo.getProfilePhoto();

      _cachedImageData = imageData;
      _lastFetchTime = DateTime.now();

      emit(ProfilePhotoLoaded(imageData));
    } catch (e, stack) {
      log('[ProfilePhotoCubit] Get Error: $e\n$stack');
      emit(ProfilePhotoLoadError(e.toString()));
    }
  }

  void clearCache() {
    _cachedImageData = null;
    _lastFetchTime = null;
    emit(ProfilePhotoInitial());
  }
}