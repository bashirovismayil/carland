class UploadCarPhotoResponse {
  final String? message;
  final String? photoUrl;

  UploadCarPhotoResponse({
    this.message,
    this.photoUrl,
  });

  UploadCarPhotoResponse copyWith({
    String? message,
    String? photoUrl,
  }) {
    return UploadCarPhotoResponse(
      message: message ?? this.message,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory UploadCarPhotoResponse.fromJson(Map<String, dynamic> json) =>
      UploadCarPhotoResponse(
        message: json['message'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'photoUrl': photoUrl,
  };
}