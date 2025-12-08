import 'dart:typed_data';

import '../../../data/remote/models/remote/upload_profile_photo_response.dart';

abstract class ProfilePhotoState {
  const ProfilePhotoState();

  List<Object?> get props => [];
}

class ProfilePhotoInitial extends ProfilePhotoState {}

class ProfilePhotoUploading extends ProfilePhotoState {}

class ProfilePhotoUploadSuccess extends ProfilePhotoState {
  final UploadProfilePhotoResponse response;

  const ProfilePhotoUploadSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ProfilePhotoUploadError extends ProfilePhotoState {
  final String message;

  const ProfilePhotoUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfilePhotoLoading extends ProfilePhotoState {}

class ProfilePhotoLoaded extends ProfilePhotoState {
  final Uint8List imageData;

  const ProfilePhotoLoaded(this.imageData);

  @override
  List<Object?> get props => [imageData];
}

class ProfilePhotoLoadError extends ProfilePhotoState {
  final String message;

  const ProfilePhotoLoadError(this.message);

  @override
  List<Object?> get props => [message];
}