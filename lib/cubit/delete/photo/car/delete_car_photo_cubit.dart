import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/remote/contractor/delete_car_photo_contractor.dart';
import '../../../../utils/di/locator.dart';
import 'delete_car_photo_state.dart';

class DeleteCarPhotoCubit extends Cubit<DeleteCarPhotoState> {
  DeleteCarPhotoCubit() : super(DeleteCarPhotoInitial()) {
    _deletePhotoRepo = locator<DeleteCarPhotoContractor>();
  }

  late final DeleteCarPhotoContractor _deletePhotoRepo;

  Future<void> deleteCarPhoto(int carId) async {
    try {
      emit(DeleteCarPhotoLoading());

      final success = await _deletePhotoRepo.deleteCarPhoto(carId);

      if (success) {
        log("Delete Car Photo Success for carId: $carId");
        emit(DeleteCarPhotoSuccess());
      } else {
        emit(DeleteCarPhotoError('Failed to delete photo'));
      }
    } catch (e) {
      emit(DeleteCarPhotoError(e.toString()));
      log("Delete Car Photo Error: $e");
    }
  }
}