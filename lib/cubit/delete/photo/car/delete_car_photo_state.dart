sealed class DeleteCarPhotoState {}

final class DeleteCarPhotoInitial extends DeleteCarPhotoState {}

final class DeleteCarPhotoLoading extends DeleteCarPhotoState {}

final class DeleteCarPhotoSuccess extends DeleteCarPhotoState {}

final class DeleteCarPhotoError extends DeleteCarPhotoState {
  final String message;
  DeleteCarPhotoError(this.message);
}