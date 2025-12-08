class GetProfilePhotoResponse {
  final String imageUrl;

  GetProfilePhotoResponse({
    required this.imageUrl,
  });

  factory GetProfilePhotoResponse.fromJson(Map<String, dynamic> json) {
    return GetProfilePhotoResponse(
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
    };
  }
}