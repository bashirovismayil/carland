import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_car_list_contractor.dart';
import '../../../data/remote/contractor/get_car_photo_contractor.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../data/remote/services/local/car_photo_cache_service.dart';
import '../../../utils/di/locator.dart';
import 'get_car_list_state.dart';

class GetCarListCubit extends Cubit<GetCarListState> {
  GetCarListCubit() : super(GetCarListInitial()) {
    _carListRepo = locator<GetCarListContractor>();
    _carPhotoRepo = locator<GetCarPhotoContractor>();
    _diskCache = locator<CarPhotoCacheService>();
  }

  late final GetCarListContractor _carListRepo;
  late final GetCarPhotoContractor _carPhotoRepo;
  late final CarPhotoCacheService _diskCache;

  /// RAM cache
  final Map<int, Uint8List> _carPhotosCache = {};

  /// Eyni carId üçün parallel request getməsin
  final Map<int, Completer<Uint8List?>> _pendingRequests = {};

  /// Hansı carId-lər üçün artıq background revalidation gedir
  final Set<int> _revalidatingIds = {};

  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  // ─── Car List ───────────────────────────────────────

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
      // RAM cache təmizlə ki, fotoğraflar təzədən yüklənsin
      _carPhotosCache.clear();

      final List<GetCarListResponse> carList = await _carListRepo.getCarList();
      log("Refresh Car List Success: ${carList.length} cars found");
      emit(GetCarListSuccess(carList));
    } catch (e) {
      log("Refresh Car List Error: $e");
      // Xəta olsa da mövcud state-i yenidən emit et ki UI refresh-dən çıxsın
      final currentState = state;
      if (currentState is GetCarListSuccess) {
        emit(GetCarListSuccess(currentState.carList));
      }
    }
  }

  // ─── Car Photo — İMZA DƏYİŞMƏYİB ──────────────────

  Future<Uint8List?> getCarPhoto(int carId) async {
    // 1) RAM cache — dərhal qaytar
    if (_carPhotosCache.containsKey(carId)) {
      log("[PhotoLoad] RAM cache hit → carId: $carId");
      // Arxada yenilə (stale-while-revalidate)
      _revalidateInBackground(carId);
      return _carPhotosCache[carId];
    }

    // 2) Artıq eyni carId üçün request gedirsə, ona qoşul
    if (_pendingRequests.containsKey(carId)) {
      log("[PhotoLoad] Joining pending request → carId: $carId");
      return _pendingRequests[carId]!.future;
    }

    // 3) Yeni request başlat
    final completer = Completer<Uint8List?>();
    _pendingRequests[carId] = completer;

    try {
      final result = await _fetchPhotoWithCache(carId);
      completer.complete(result);
      return result;
    } catch (e) {
      log("[PhotoLoad] Error → carId: $carId: $e");
      completer.complete(null);
      return null;
    } finally {
      _pendingRequests.remove(carId);
    }
  }

  Future<Uint8List?> _fetchPhotoWithCache(int carId) async {
    // Disk cache yoxla
    final diskData = await _diskCache.getPhoto(carId);
    if (diskData != null) {
      log("[PhotoLoad] Disk cache hit → carId: $carId");
      _carPhotosCache[carId] = diskData;
      // Arxada API-dən yenilə
      _revalidateInBackground(carId);
      return diskData;
    }

    // Heç bir cache yoxdur — API-dən çək
    log("[PhotoLoad] No cache, fetching from API → carId: $carId");
    final apiData = await _fetchWithRetry(carId);

    if (apiData != null) {
      _carPhotosCache[carId] = apiData;
      _diskCache.savePhoto(carId, apiData);
      log("[PhotoLoad] API success → carId: $carId");
    }

    return apiData;
  }

  /// Stale-while-revalidate: arxada API-dən yeni foto çəkir,
  /// fərqlidirsə cache-i yeniləyir. Heç bir xarici callback yoxdur —
  /// növbəti getCarPhoto çağırışında yeni foto RAM cache-dən gələcək.
  void _revalidateInBackground(int carId) {
    if (_revalidatingIds.contains(carId)) return;
    _revalidatingIds.add(carId);

    _fetchWithRetry(carId).then((freshData) {
      if (freshData == null) return;

      final currentData = _carPhotosCache[carId];
      final isChanged =
          currentData == null || !listEquals(freshData, currentData);

      if (isChanged) {
        log("[PhotoLoad] Photo changed on server → carId: $carId");
        _carPhotosCache[carId] = freshData;
        _diskCache.savePhoto(carId, freshData);
      }
    }).catchError((e) {
      log("[PhotoLoad] Revalidation failed → carId: $carId: $e");
    }).whenComplete(() {
      _revalidatingIds.remove(carId);
    });
  }

  /// Retry mexanizması
  Future<Uint8List?> _fetchWithRetry(int carId) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final Uint8List photoBytes = await _carPhotoRepo.getCarPhoto(carId);
        return photoBytes;
      } catch (e) {
        log("[PhotoLoad] Attempt $attempt/$_maxRetries failed for carId $carId: $e");
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay * attempt);
        }
      }
    }
    log("[PhotoLoad] All retries exhausted for carId: $carId");
    return null;
  }

  // ─── Cache Management ───────────────────────────────

  void removeCarLocally(int carId) {
    final currentState = state;
    if (currentState is GetCarListSuccess) {
      final updatedList =
      currentState.carList.where((c) => c.carId != carId).toList();
      emit(GetCarListSuccess(updatedList));
    }
    invalidatePhotoCache(carId);
  }

  void invalidatePhotoCache(int carId) {
    _carPhotosCache.remove(carId);
    _diskCache.deletePhoto(carId);
    log("[PhotoLoad] Cache invalidated → carId: $carId");
  }

  void clearCache() {
    _carPhotosCache.clear();
    _diskCache.clearAll();
    log("[PhotoLoad] All caches cleared");
  }
}