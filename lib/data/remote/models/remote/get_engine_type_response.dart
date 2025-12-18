class GetEngineTypeListResponse {
  final int engineTypeId;
  final String engineType;
  final String status;

  GetEngineTypeListResponse({
    required this.engineTypeId,
    required this.engineType,
    required this.status,
  });

  GetEngineTypeListResponse copyWith({
    int? engineTypeId,
    String? engineType,
    String? status,
  }) =>
      GetEngineTypeListResponse(
        engineTypeId: engineTypeId ?? this.engineTypeId,
        engineType: engineType ?? this.engineType,
        status: status ?? this.status,
      );

  factory GetEngineTypeListResponse.fromJson(Map<String, dynamic> json) =>
      GetEngineTypeListResponse(
        engineTypeId: json['engineTypeId'] as int,
        engineType: json['engineType'] as String,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
    'engineTypeId': engineTypeId,
    'engineType': engineType,
    'status': status,
  };
}