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

// ─── Replay-1 stream slot ──────────────────────────────────────────────────
//
// StreamController.broadcast() keçmişi yadda saxlamır.
// async* generator isə lazy-dir — subscribe anında deyil, yield-ə çatanda emit edir,
// bu da broadcast stream ilə birləşdirildikdə event itirilməsinə səbəb olur.
//
// Həll: hər yeni subscriber üçün ayrı StreamController açırıq.
// onListen callback-i dərhal son dəyəri push edir, sonra broadcast
// stream-ə qoşulur və gələcək event-ləri ötürür. Subscriber disconnect
// olanda hər şey təmizlənir.

class _PhotoSlot {
  Uint8List? _lastValue;
  bool _hasValue = false;
  final List<StreamController<Uint8List?>> _subscribers = [];

  Stream<Uint8List?> get stream {
    late StreamController<Uint8List?> ctrl;
    ctrl = StreamController<Uint8List?>(
      onListen: () {
        // Subscriber qoşulduğu anda son dəyəri dərhal göndər
        if (_hasValue) ctrl.add(_lastValue);
      },
      onCancel: () {
        _subscribers.remove(ctrl);
        ctrl.close();
      },
    );
    _subscribers.add(ctrl);
    return ctrl.stream;
  }

  void add(Uint8List? value) {
    _lastValue = value;
    _hasValue = true;
    for (final ctrl in List.of(_subscribers)) {
      if (!ctrl.isClosed) ctrl.add(value);
    }
  }

  void close() {
    for (final ctrl in List.of(_subscribers)) {
      if (!ctrl.isClosed) ctrl.close();
    }
    _subscribers.clear();
  }
}

// ──────────────────────────────────────────────────────────────────────────────

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

  /// Her carId üçün bir replay-1 slot
  final Map<int, _PhotoSlot> _photoSlots = {};

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
      _carPhotosCache.clear();
      final List<GetCarListResponse> carList = await _carListRepo.getCarList();
      log("Refresh Car List Success: ${carList.length} cars found");
      emit(GetCarListSuccess(carList));
    } catch (e) {
      log("Refresh Car List Error: $e");
      final currentState = state;
      if (currentState is GetCarListSuccess) {
        emit(GetCarListSuccess(currentState.carList));
      }
    }
  }

  // ─── Car Photo — Stream API ──────────────────────────

  /// Widget-lərin dinləməsi üçün stream qaytarır.
  /// Subscribe anında son bilinən dəyər dərhal (onListen callback-i ilə) emit edilir.
  Stream<Uint8List?> watchCarPhoto(int carId) {
    final slot = _photoSlots.putIfAbsent(carId, () {
      final s = _PhotoSlot();
      _fetchPhotoWithCache(carId).then((data) => s.add(data));
      return s;
    });
    return slot.stream;
  }

  void _pushToSlot(int carId, Uint8List? data) {
    _photoSlots[carId]?.add(data);
  }

  Future<Uint8List?> _fetchPhotoWithCache(int carId) async {
    // 1) Eyni carId üçün artıq request gedirsə ona qoşul
    if (_pendingRequests.containsKey(carId)) {
      log("[PhotoLoad] Joining pending request → carId: $carId");
      return _pendingRequests[carId]!.future;
    }

    // 2) RAM cache — dərhal qaytar, arxada yenilə
    if (_carPhotosCache.containsKey(carId)) {
      log("[PhotoLoad] RAM cache hit → carId: $carId");
      _revalidateInBackground(carId);
      return _carPhotosCache[carId];
    }

    // 3) Yeni request başlat
    final completer = Completer<Uint8List?>();
    _pendingRequests[carId] = completer;

    try {
      final diskData = await _diskCache.getPhoto(carId);
      if (diskData != null) {
        log("[PhotoLoad] Disk cache hit → carId: $carId");
        _carPhotosCache[carId] = diskData;
        completer.complete(diskData);
        _revalidateInBackground(carId);
        return diskData;
      }

      log("[PhotoLoad] No cache, fetching from API → carId: $carId");
      final apiData = await _fetchWithRetry(carId);

      if (apiData != null) {
        _carPhotosCache[carId] = apiData;
        _diskCache.savePhoto(carId, apiData);
        log("[PhotoLoad] API success → carId: $carId");
      }

      completer.complete(apiData);
      return apiData;
    } catch (e) {
      log("[PhotoLoad] Error → carId: $carId: $e");
      completer.complete(null);
      return null;
    } finally {
      _pendingRequests.remove(carId);
    }
  }

  /// Stale-while-revalidate
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
        _pushToSlot(carId, freshData);
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

  /// Widget initialData üçün: RAM cache-dəki mövcud fotoğrafı qaytarır.
  Uint8List? getCachedPhoto(int carId) => _carPhotosCache[carId];

  /// Geriye dönük uyumluluk üçün saxlanıldı.
  Future<Uint8List?> getCarPhoto(int carId) async {
    if (_carPhotosCache.containsKey(carId)) {
      _revalidateInBackground(carId);
      return _carPhotosCache[carId];
    }
    return _fetchPhotoWithCache(carId);
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
    _pushToSlot(carId, null);
    log("[PhotoLoad] Cache invalidated → carId: $carId");
  }

  /// Yeni foto yüklənəndən sonra çağır.
  /// Cache-i təmizləyib API-dən yeni fotoğrafı çəkir və bütün widget-lərə push edir.
  Future<void> refreshPhotoCache(int carId) async {
    _carPhotosCache.remove(carId);
    _diskCache.deletePhoto(carId);
    log("[PhotoLoad] Refreshing photo after upload → carId: $carId");
    final data = await _fetchPhotoWithCache(carId);
    _pushToSlot(carId, data);
  }

  void clearCache() {
    _carPhotosCache.clear();
    _diskCache.clearAll();
    for (final carId in _photoSlots.keys) {
      _pushToSlot(carId, null);
    }
    log("[PhotoLoad] All caches cleared");
  }

  // ─── Lifecycle ──────────────────────────────────────

  @override
  Future<void> close() {
    for (final slot in _photoSlots.values) {
      slot.close();
    }
    _photoSlots.clear();
    return super.close();
  }
}