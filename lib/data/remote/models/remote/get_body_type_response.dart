class GetBodyTypeListResponse {
  final int bodyTypeId;
  final String bodyType;
  final String status;

  GetBodyTypeListResponse({
    required this.bodyTypeId,
    required this.bodyType,
    required this.status,
  });

  GetBodyTypeListResponse copyWith({
    int? bodyTypeId,
    String? bodyType,
    String? status,
  }) =>
      GetBodyTypeListResponse(
        bodyTypeId: bodyTypeId ?? this.bodyTypeId,
        bodyType: bodyType ?? this.bodyType,
        status: status ?? this.status,
      );

  factory GetBodyTypeListResponse.fromJson(Map<String, dynamic> json) =>
      GetBodyTypeListResponse(
        bodyTypeId: json['bodyTypeId'] as int,
        bodyType: json['bodyType'] as String,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
    'bodyTypeId': bodyTypeId,
    'bodyType': bodyType,
    'status': status,
  };
}