class ModelListResponse {
  final int? modelId;
  final String? modelName;
  final int? brandId;
  final String? status;

  ModelListResponse({
    this.modelId,
    this.modelName,
    this.brandId,
    this.status,
  });

  ModelListResponse copyWith({
    int? modelId,
    String? modelName,
    int? brandId,
    String? status,
  }) =>
      ModelListResponse(
        modelId: modelId ?? this.modelId,
        modelName: modelName ?? this.modelName,
        brandId: brandId ?? this.brandId,
        status: status ?? this.status,
      );

  factory ModelListResponse.fromJson(Map<String, dynamic> json) {
    return ModelListResponse(
      modelId: json['modelId'] as int?,
      modelName: json['modelName'] as String?,
      brandId: json['brandId'] as int?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'modelId': modelId,
    'modelName': modelName,
    'brandId': brandId,
    'status': status,
  };
}