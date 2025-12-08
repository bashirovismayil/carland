class UploadProfilePhotoResponse {
  final String message;

  UploadProfilePhotoResponse({
    required this.message,
  });

  factory UploadProfilePhotoResponse.fromJson(Map<String, dynamic> json) {
    return UploadProfilePhotoResponse(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}