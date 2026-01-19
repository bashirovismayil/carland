class GetCarServicesResponse {
  final int carId;
  final String vin;
  final List<ResponseList> responseList;

  GetCarServicesResponse({
    required this.carId,
    required this.vin,
    required this.responseList,
  });

  GetCarServicesResponse copyWith({
    int? carId,
    String? vin,
    List<ResponseList>? responseList,
  }) =>
      GetCarServicesResponse(
        carId: carId ?? this.carId,
        vin: vin ?? this.vin,
        responseList: responseList ?? this.responseList,
      );

  factory GetCarServicesResponse.fromJson(Map<String, dynamic> json) =>
      GetCarServicesResponse(
        carId: json['carId'] as int,
        vin: json['vin'] as String,
        responseList: (json['responseList'] as List)
            .map((item) => ResponseList.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'carId': carId,
        'vin': vin,
        'responseList': responseList.map((item) => item.toJson()).toList(),
      };
}

class ResponseList {
  final int percentageId;
  final String serviceName;
  final String actionType;
  final int intervalKm;
  final int intervalMonth;
  final int kmPercentage;
  final int monthPercentage;
  final int monthPercentageDigit;
  final int remainingKm;
  final String remainingMonths;
  final int lastServiceKm;
  final String lastServiceDate;
  final int nextServiceKm;
  final String nextServiceDate;

  ResponseList({
    required this.percentageId,
    required this.serviceName,
    required this.actionType,
    required this.intervalKm,
    required this.intervalMonth,
    required this.kmPercentage,
    required this.monthPercentage,
    required this.monthPercentageDigit,
    required this.remainingKm,
    required this.remainingMonths,
    required this.lastServiceKm,
    required this.lastServiceDate,
    required this.nextServiceKm,
    required this.nextServiceDate,
  });

  ResponseList copyWith({
    int? percentageId,
    String? serviceName,
    String? actionType,
    int? intervalKm,
    int? intervalMonth,
    int? kmPercentage,
    int? monthPercentage,
    int? monthPercentageDigit,
    int? remainingKm,
    String? remainingMonths,
    int? lastServiceKm,
    String? lastServiceDate,
    int? nextServiceKm,
    String? nextServiceDate,
  }) =>
      ResponseList(
        percentageId: percentageId ?? this.percentageId,
        serviceName: serviceName ?? this.serviceName,
        actionType: actionType ?? this.actionType,
        intervalKm: intervalKm ?? this.intervalKm,
        intervalMonth: intervalMonth ?? this.intervalMonth,
        kmPercentage: kmPercentage ?? this.kmPercentage,
        monthPercentage: monthPercentage ?? this.monthPercentage,
        monthPercentageDigit: monthPercentageDigit ?? this.monthPercentageDigit,
        remainingKm: remainingKm ?? this.remainingKm,
        remainingMonths: remainingMonths ?? this.remainingMonths,
        lastServiceKm: lastServiceKm ?? this.lastServiceKm,
        lastServiceDate: lastServiceDate ?? this.lastServiceDate,
        nextServiceKm: nextServiceKm ?? this.nextServiceKm,
        nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      );

  factory ResponseList.fromJson(Map<String, dynamic> json) {

    return ResponseList(
      percentageId: json['percentageId'] as int? ?? 0,
      serviceName: json['serviceName'] as String? ?? '',
      actionType: json['actionType'] as String? ?? '',
      intervalKm: json['intervalKm'] as int? ?? 0,
      intervalMonth: json['intervalMonth'] as int? ?? 0,
      kmPercentage: json['kmPercentage'] as int? ?? 0,
      monthPercentage: json['monthPercentage'] as int? ?? 0,
      monthPercentageDigit: json['monthPercentageDigit'] as int? ?? 0,
      remainingKm: json['remainingKm'] as int? ?? 0,
      remainingMonths: json['remainingMonths'] as String? ?? '0',
      lastServiceKm: json['lastServiceKm'] as int? ?? 0,
      lastServiceDate: json['lastServiceDate'] as String? ?? '',
      nextServiceKm: json['nextServiceKm'] as int? ?? 0,
      nextServiceDate: json['nextServiceDate'] as String? ?? '',
    );
  }

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

class LastServiceDate {
  final int year;
  final int month;
  final int day;

  LastServiceDate({
    required this.year,
    required this.month,
    required this.day,
  });

  LastServiceDate copyWith({
    int? year,
    int? month,
    int? day,
  }) =>
      LastServiceDate(
        year: year ?? this.year,
        month: month ?? this.month,
        day: day ?? this.day,
      );

  factory LastServiceDate.fromJson(Map<String, dynamic> json) =>
      LastServiceDate(
        year: json['year'] as int? ?? 0,
        month: json['month'] as int? ?? 0,
        day: json['day'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'day': day,
      };

  String toFormattedString() {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }
}
