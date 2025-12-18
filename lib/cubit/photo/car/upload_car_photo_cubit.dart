import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/upload_car_photo_contractor.dart';
import '../../../data/remote/models/remote/upload_car_photo_response.dart';
import '../../../utils/di/locator.dart';
import 'upload_car_photo_state.dart';

class UploadCarPhotoCubit extends Cubit<UploadCarPhotoState> {
  UploadCarPhotoCubit() : super(UploadCarPhotoInitial()) {
    _photoRepo = locator<UploadCarPhotoContractor>();
  }
  late final UploadCarPhotoContractor _photoRepo;
  Future<void> uploadCarPhoto({
    required String carId,
    required File imageFile,
  }) async {
    try {
      emit(UploadCarPhotoLoading());
      final UploadCarPhotoResponse response = await _photoRepo.uploadCarPhoto(
        carId: carId,
        imageFile: imageFile,
      );
      log("Upload Car Photo Success: ${response.toJson()}");
      emit(UploadCarPhotoSuccess(response));
    } catch (e) {
      emit(UploadCarPhotoError(e.toString()));
      log("Upload Car Photo Error: $e");
    }
  }
  void reset() {
    emit(UploadCarPhotoInitial());
  }
}