class GetYearListResponse {
  final int modelYearId;
  final int modelYear;
  final String status;

  GetYearListResponse({
    required this.modelYearId,
    required this.modelYear,
    required this.status,
  });

  GetYearListResponse copyWith({
    int? modelYearId,
    int? modelYear,
    String? status,
  }) =>
      GetYearListResponse(
        modelYearId: modelYearId ?? this.modelYearId,
        modelYear: modelYear ?? this.modelYear,
        status: status ?? this.status,
      );

  factory GetYearListResponse.fromJson(Map<String, dynamic> json) =>
      GetYearListResponse(
        modelYearId: json['modelYearId'] as int,
        modelYear: json['modelYear'] as int,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
    'modelYearId': modelYearId,
    'modelYear': modelYear,
    'status': status,
  };
}