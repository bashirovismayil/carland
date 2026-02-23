import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_car_list_contractor.dart';
import '../../../data/remote/contractor/get_car_photo_contractor.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../utils/di/locator.dart';
import 'get_car_list_state.dart';

class GetCarListCubit extends Cubit<GetCarListState> {
  GetCarListCubit() : super(GetCarListInitial()) {
    _carListRepo = locator<GetCarListContractor>();
    _carPhotoRepo = locator<GetCarPhotoContractor>();
  }

  late final GetCarListContractor _carListRepo;
  late final GetCarPhotoContractor _carPhotoRepo;
  final Map<int, Uint8List> _carPhotosCache = {};

  Future<void> getCarList() async {
    try {
      emit(GetCarListLoading());

      final List<GetCarListResponse> carList = await _carListRepo.getCarList();

      log("Get Car List Success: ${carList.length} cars found");
      emit(GetCarListSuccess(carList));
    } catch (e) {
      emit(GetCarListError(e.toString()));
      log("Get Car List Error: $e");
    }
  }

  Future<void> refreshCarList() async {
    try {
      final List<GetCarListResponse> carList = await _carListRepo.getCarList();

      log("Refresh Car List Success: ${carList.length} cars found");
      emit(GetCarListSuccess(carList));
    } catch (e) {
      log("Refresh Car List Error: $e");
    }
  }

  Future<Uint8List?> getCarPhoto(int carId) async {
    try {
      if (_carPhotosCache.containsKey(carId)) {
        log("Get Car Photo: Using cached photo for carId: $carId");
        return _carPhotosCache[carId];
      }

      log("Get Car Photo: Fetching photo for carId: $carId");
      final Uint8List photoBytes = await _carPhotoRepo.getCarPhoto(carId);

      _carPhotosCache[carId] = photoBytes;

      log("Get Car Photo Success: Photo received for carId: $carId");
      return photoBytes;
    } catch (e) {
      log("Get Car Photo Error for carId $carId: $e");
      return null;
    }
  }

  void removeCarLocally(int carId) {
    final currentState = state;
    if (currentState is GetCarListSuccess) {
      final updatedList = currentState.carList
          .where((c) => c.carId != carId)
          .toList();
      emit(GetCarListSuccess(updatedList));
    }
  }

  void invalidatePhotoCache(int carId) {
    if (_carPhotosCache.containsKey(carId)) {
      _carPhotosCache.remove(carId);
      log("Photo cache invalidated for carId: $carId");
    }
  }

  void clearCache() {
    _carPhotosCache.clear();
    log("All photo cache cleared");
  }
}