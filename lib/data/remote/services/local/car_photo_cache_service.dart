import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Fotoğrafları diskdə saxlayır. App kill olsa belə qalır.
///
/// pubspec.yaml-a əlavə et (əgər yoxdursa):
///   path_provider: ^2.1.0
class CarPhotoCacheService {
  static const String _cacheDir = 'car_photos';

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDir');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  String _getFileName(int carId) => 'car_photo_$carId.bin';

  /// Disk cache-dən fotoğrafı oxuyur. Yoxdursa null qaytarır.
  Future<Uint8List?> getPhoto(int carId) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/${_getFileName(carId)}');

      if (await file.exists()) {
        // 7 gündən köhnədirsə expired say
        final lastModified = await file.lastModified();
        final age = DateTime.now().difference(lastModified);
        if (age.inDays > 7) {
          log('[CarPhotoCache] Cache expired for carId: $carId');
          await file.delete();
          return null;
        }

        log('[CarPhotoCache] Disk cache hit for carId: $carId');
        return await file.readAsBytes();
      }

      return null;
    } catch (e) {
      log('[CarPhotoCache] Read error for carId $carId: $e');
      return null;
    }
  }

  /// Fotoğrafı diskə yazır.
  Future<void> savePhoto(int carId, Uint8List bytes) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/${_getFileName(carId)}');
      await file.writeAsBytes(bytes, flush: true);
      log('[CarPhotoCache] Saved to disk for carId: $carId');
    } catch (e) {
      log('[CarPhotoCache] Write error for carId $carId: $e');
    }
  }

  /// Bir fotoğrafı cache-dən silir.
  Future<void> deletePhoto(int carId) async {
    try {
      final dir = await _getCacheDirectory();
      final file = File('${dir.path}/${_getFileName(carId)}');
      if (await file.exists()) {
        await file.delete();
        log('[CarPhotoCache] Deleted for carId: $carId');
      }
    } catch (e) {
      log('[CarPhotoCache] Delete error for carId $carId: $e');
    }
  }

  /// Bütün cache-i təmizləyir.
  Future<void> clearAll() async {
    try {
      final dir = await _getCacheDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        log('[CarPhotoCache] All cleared');
      }
    } catch (e) {
      log('[CarPhotoCache] Clear all error: $e');
    }
  }
}