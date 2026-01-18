class EditCarServicesResponse {
  final int percentageId;
  final String serviceName;
  final String actionType;
  final int? intervalKm;
  final int? intervalMonth;
  final int kmPercentage;
  final int monthPercentage;
  final int remainingKm;
  final String remainingMonths;
  final int lastServiceKm;
  final String lastServiceDate;
  final int nextServiceKm;
  final String nextServiceDate;

  EditCarServicesResponse({
    required this.percentageId,
    required this.serviceName,
    required this.actionType,
    this.intervalKm,
    this.intervalMonth,
    required this.kmPercentage,
    required this.monthPercentage,
    required this.remainingKm,
    required this.remainingMonths,
    required this.lastServiceKm,
    required this.lastServiceDate,
    required this.nextServiceKm,
    required this.nextServiceDate,
  });

  EditCarServicesResponse copyWith({
    int? percentageId,
    String? serviceName,
    String? actionType,
    int? intervalKm,
    int? intervalMonth,
    int? kmPercentage,
    int? monthPercentage,
    int? remainingKm,
    String? remainingMonths,
    int? lastServiceKm,
    String? lastServiceDate,
    int? nextServiceKm,
    String? nextServiceDate,
  }) =>
      EditCarServicesResponse(
        percentageId: percentageId ?? this.percentageId,
        serviceName: serviceName ?? this.serviceName,
        actionType: actionType ?? this.actionType,
        intervalKm: intervalKm ?? this.intervalKm,
        intervalMonth: intervalMonth ?? this.intervalMonth,
        kmPercentage: kmPercentage ?? this.kmPercentage,
        monthPercentage: monthPercentage ?? this.monthPercentage,
        remainingKm: remainingKm ?? this.remainingKm,
        remainingMonths: remainingMonths ?? this.remainingMonths,
        lastServiceKm: lastServiceKm ?? this.lastServiceKm,
        lastServiceDate: lastServiceDate ?? this.lastServiceDate,
        nextServiceKm: nextServiceKm ?? this.nextServiceKm,
        nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      );

  factory EditCarServicesResponse.fromJson(Map<String, dynamic> json) =>
      EditCarServicesResponse(
        percentageId: json['percentageId'] as int,
        serviceName: json['serviceName'] as String,
        actionType: json['actionType'] as String,
        intervalKm: json['intervalKm'] as int?,
        intervalMonth: json['intervalMonth'] as int?,
        kmPercentage: json['kmPercentage'] as int,
        monthPercentage: json['monthPercentage'] as int,
        remainingKm: json['remainingKm'] as int,
        remainingMonths: json['remainingMonths'] as String,
        lastServiceKm: json['lastServiceKm'] as int,
        lastServiceDate: json['lastServiceDate'] as String,
        nextServiceKm: json['nextServiceKm'] as int,
        nextServiceDate: json['nextServiceDate'] as String,
      );

  Map<String, dynamic> toJson() => {
    'percentageId': percentageId,
    'serviceName': serviceName,
    'actionType': actionType,
    'intervalKm': intervalKm,
    'intervalMonth': intervalMonth,
    'kmPercentage': kmPercentage,
    'monthPercentage': monthPercentage,
    'remainingKm': remainingKm,
    'remainingMonths': remainingMonths,
    'lastServiceKm': lastServiceKm,
    'lastServiceDate': lastServiceDate,
    'nextServiceKm': nextServiceKm,
    'nextServiceDate': nextServiceDate,
  };
}