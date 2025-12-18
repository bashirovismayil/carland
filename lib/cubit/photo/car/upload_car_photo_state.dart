import '../../../data/remote/models/remote/upload_car_photo_response.dart';

sealed class UploadCarPhotoState {}

final class UploadCarPhotoInitial extends UploadCarPhotoState {}

final class UploadCarPhotoLoading extends UploadCarPhotoState {}

final class UploadCarPhotoSuccess extends UploadCarPhotoState {
  final UploadCarPhotoResponse response;
  UploadCarPhotoSuccess(this.response);
}

final class UploadCarPhotoError extends UploadCarPhotoState {
  final String message;
  UploadCarPhotoError(this.message);
}