class GetCarServicesResponse {
  final String? serviceName;
  final String? actionType;
  final int? intervalKm;
  final int? intervalMonth;
  final int? kmPercentage;
  final double? monthPercentage;
  final String? remainingKm;
  final String? remainingMonths;

  GetCarServicesResponse({
    this.serviceName,
    this.actionType,
    this.intervalKm,
    this.intervalMonth,
    this.kmPercentage,
    this.monthPercentage,
    this.remainingKm,
    this.remainingMonths,
  });

  GetCarServicesResponse copyWith({
    String? serviceName,
    String? actionType,
    int? intervalKm,
    int? intervalMonth,
    int? kmPercentage,
    double? monthPercentage,
    String? remainingKm,
    String? remainingMonths,
  }) =>
      GetCarServicesResponse(
        serviceName: serviceName ?? this.serviceName,
        actionType: actionType ?? this.actionType,
        intervalKm: intervalKm ?? this.intervalKm,
        intervalMonth: intervalMonth ?? this.intervalMonth,
        kmPercentage: kmPercentage ?? this.kmPercentage,
        monthPercentage: monthPercentage ?? this.monthPercentage,
        remainingKm: remainingKm ?? this.remainingKm,
        remainingMonths: remainingMonths ?? this.remainingMonths,
      );

  factory GetCarServicesResponse.fromJson(Map<String, dynamic> json) {
    return GetCarServicesResponse(
      serviceName: json['serviceName'] as String?,
      actionType: json['actionType'] as String?,
      intervalKm: _parseInt(json['intervalKm']),
      intervalMonth: _parseInt(json['intervalMonth']),
      kmPercentage: _parseInt(json['kmPercentage']),
      monthPercentage: _parseDouble(json['monthPercentage']),
      remainingKm: json['remainingKm'] as String?,
      remainingMonths: json['remainingMonths'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'serviceName': serviceName,
    'actionType': actionType,
    'intervalKm': intervalKm,
    'intervalMonth': intervalMonth,
    'kmPercentage': kmPercentage,
    'monthPercentage': monthPercentage,
    'remainingKm': remainingKm,
    'remainingMonths': remainingMonths,
  };
}