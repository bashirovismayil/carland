class GetTransmissionTypeListResponse {
  final int transmissionTypeId;
  final String transmissionType;
  final String status;

  GetTransmissionTypeListResponse({
    required this.transmissionTypeId,
    required this.transmissionType,
    required this.status,
  });

  GetTransmissionTypeListResponse copyWith({
    int? transmissionTypeId,
    String? transmissionType,
    String? status,
  }) =>
      GetTransmissionTypeListResponse(
        transmissionTypeId: transmissionTypeId ?? this.transmissionTypeId,
        transmissionType: transmissionType ?? this.transmissionType,
        status: status ?? this.status,
      );

  factory GetTransmissionTypeListResponse.fromJson(Map<String, dynamic> json) =>
      GetTransmissionTypeListResponse(
        transmissionTypeId: json['transmissionTypeId'] as int,
        transmissionType: json['transmissionType'] as String,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
    'transmissionTypeId': transmissionTypeId,
    'transmissionType': transmissionType,
    'status': status,
  };
}