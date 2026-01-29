import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../../cubit/services/get_services/get_car_services_cubit.dart';
import '../../../../data/remote/models/remote/get_car_list_response.dart';

class CarServicesController extends ChangeNotifier {
  final GetCarListCubit carListCubit;
  final GetCarServicesCubit carServicesCubit;

  late int currentCarIndex;
  late List<GetCarListResponse> carList;
  final Map<int, Future<Uint8List?>> photoCache = {};
  final Map<int, int> photoCacheVersion = {};
  Timer? _debounce;

  CarServicesController({
    required this.carListCubit,
    required this.carServicesCubit,
    required List<GetCarListResponse> initialCarList,
    required int initialCarIndex,
  }) {
    carList = List.from(initialCarList);
    currentCarIndex = initialCarIndex;
    _preloadPhotos();
    loadCarServices(carList[currentCarIndex].carId);
  }

  void _preloadPhotos() {
    for (int i = currentCarIndex - 1; i <= currentCarIndex + 1; i++) {
      if (i >= 0 && i < carList.length) {
        final carId = carList[i].carId;
        photoCache.putIfAbsent(carId, () => carListCubit.getCarPhoto(carId));
      }
    }
  }

  void loadCarServices(int carId) {
    carServicesCubit.getCarServices(carId);
  }

  void refreshCurrentCarServices() {
    loadCarServices(carList[currentCarIndex].carId);
  }

  void onPageChanged(int index) {
    currentCarIndex = index;
    notifyListeners();

    if (index >= carList.length) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      loadCarServices(carList[index].carId);
    });
    _preloadPhotos();
  }

  void invalidatePhotoCache(int carId) {
    carListCubit.invalidatePhotoCache(carId);
    photoCache.remove(carId);
    photoCacheVersion[carId] = (photoCacheVersion[carId] ?? 0) + 1;
    photoCache[carId] = carListCubit.getCarPhoto(carId);
    notifyListeners();
  }

  void updateCarInList(int carId, {
    String? plateNumber,
    String? color,
    int? mileage,
    int? modelYear,
    String? engineType,
    int? engineVolume,
    String? transmissionType,
    String? bodyType,
  }) {
    final index = carList.indexWhere((car) => car.carId == carId);
    if (index != -1) {
      carList[index] = carList[index].copyWith(
        plateNumber: plateNumber,
        color: color,
        mileage: mileage,
        modelYear: modelYear,
        engineType: engineType,
        engineVolume: engineVolume,
        transmissionType: transmissionType,
        bodyType: bodyType,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<Uint8List?> getCarPhoto(int carId) {
    return photoCache.putIfAbsent(carId, () => carListCubit.getCarPhoto(carId));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
