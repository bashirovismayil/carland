class GetCarRecordsResponse {
  final int id;
  final String serviceName;
  final String actionType;
  final DateTime? doneDate;
  final int? doneKm;
  final dynamic message;

  GetCarRecordsResponse({
    required this.id,
    required this.serviceName,
    required this.actionType,
    this.doneDate,
    this.doneKm,
    this.message,
  });

  factory GetCarRecordsResponse.fromJson(Map<String, dynamic> json) =>
      GetCarRecordsResponse(
        id: json['id'] as int,
        serviceName: json['serviceName'] as String,
        actionType: json['actionType'] as String,
        doneDate: json['doneDate'] != null
            ? DateTime.parse(json['doneDate'] as String)
            : null,
        doneKm: json['doneKm'] as int?,
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceName': serviceName,
    'actionType': actionType,
    'doneDate': doneDate?.toIso8601String(),
    'doneKm': doneKm,
    'message': message,
  };

  GetCarRecordsResponse copyWith({
    int? id,
    String? serviceName,
    String? actionType,
    DateTime? doneDate,
    int? doneKm,
    dynamic message,
  }) =>
      GetCarRecordsResponse(
        id: id ?? this.id,
        serviceName: serviceName ?? this.serviceName,
        actionType: actionType ?? this.actionType,
        doneDate: doneDate ?? this.doneDate,
        doneKm: doneKm ?? this.doneKm,
        message: message ?? this.message,
      );
}