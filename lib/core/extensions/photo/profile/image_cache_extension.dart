import 'dart:typed_data';
import 'package:flutter/material.dart';
extension ImageCacheExtension on State {
  static Uint8List? _cachedProfileImage;
  static DateTime? _lastCacheTime;
  static const Duration _defaultCacheExpiry = Duration(minutes: 5);

  Uint8List? loadCachedImage({Duration? cacheExpiry}) {
    final expiry = cacheExpiry ?? _defaultCacheExpiry;

    if (_cachedProfileImage != null && _lastCacheTime != null) {
      final now = DateTime.now();
      final cacheAge = now.difference(_lastCacheTime!);

      if (cacheAge < expiry) {
        return _cachedProfileImage;
      } else {
        clearImageCache();
      }
    }
    return null;
  }

  void updateImageCache(Uint8List imageData) {
    _cachedProfileImage = imageData;
    _lastCacheTime = DateTime.now();
  }

  void clearImageCache() {
    _cachedProfileImage = null;
    _lastCacheTime = null;
  }

  bool get hasCachedImage {
    return _cachedProfileImage != null && _lastCacheTime != null;
  }

  int get cacheAgeInSeconds {
    if (_lastCacheTime == null) return -1;
    return DateTime.now().difference(_lastCacheTime!).inSeconds;
  }

  bool isCacheExpired({Duration? cacheExpiry}) {
    if (_lastCacheTime == null) return true;
    final expiry = cacheExpiry ?? _defaultCacheExpiry;
    final cacheAge = DateTime.now().difference(_lastCacheTime!);
    return cacheAge >= expiry;
  }

  void forceRefreshCache() {
    clearImageCache();
  }

  Uint8List? getCachedImageIfValid({Duration? cacheExpiry}) {
    if (isCacheExpired(cacheExpiry: cacheExpiry)) {
      clearImageCache();
      return null;
    }
    return _cachedProfileImage;
  }
}
