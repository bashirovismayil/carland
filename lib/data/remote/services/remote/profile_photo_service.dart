import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/dio/auth_dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../utils/di/locator.dart';
import '../../models/remote/upload_profile_photo_response.dart';
import '../local/language_local_service.dart';

class ProfilePhotoService {
  final languageService = locator<LanguageLocalService>();

  Future<UploadProfilePhotoResponse> uploadProfilePhoto(File imageFile) async {
    log('[ProfilePhotoService] Uploading profile photo...');
    final currentLanguage = languageService.currentLanguage;
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final Response resp = await authDio.post(
        ApiConstants.uploadProfilePhoto,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept-Language': currentLanguage,
            'X-Client-Timezone': 'Asia/Baku',
          },
        ),
      );

      log('[ProfilePhotoService] Upload Response Status: ${resp.statusCode}');
      log('[ProfilePhotoService] Upload Response Data: ${resp.data}');

      return UploadProfilePhotoResponse.fromJson(
          resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log('[ProfilePhotoService] Upload DioException: ${e.response?.statusCode}');

      if (e.response?.statusCode == 400) {
        throw Exception('INVALID_FILE_FORMAT');
      } else if (e.response?.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else if (e.response?.statusCode == 413) {
        throw Exception('FILE_TOO_LARGE');
      } else {
        throw Exception('Upload failed: ${e.response?.statusCode}');
      }
    } catch (e) {
      log('[ProfilePhotoService] Upload Error: $e');
      rethrow;
    }
  }

  Future<Uint8List> getProfilePhoto() async {
    log('[ProfilePhotoService] Getting profile photo...');
    final currentLanguage = languageService.currentLanguage;
    try {
      final Response resp = await authDio.get(
        ApiConstants.getProfilePhoto,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'image/*',
            'Accept-Language': currentLanguage,
            'X-Client-Timezone': 'Asia/Baku'
          },
        ),
      );

      log('[ProfilePhotoService] Get Response Status: ${resp.statusCode}');
      log('[ProfilePhotoService] Get Response Data Length: ${resp.data.length}');

      return resp.data as Uint8List;
    } on DioException catch (e) {
      log('[ProfilePhotoService] Get DioException: ${e.response?.statusCode}');

      if (e.response?.statusCode == 404) {
        throw Exception('PROFILE_PHOTO_NOT_FOUND');
      } else if (e.response?.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        throw Exception('Get profile photo failed: ${e.response?.statusCode}');
      }
    } catch (e) {
      log('[ProfilePhotoService] Get Error: $e');
      rethrow;
    }
  }
}
