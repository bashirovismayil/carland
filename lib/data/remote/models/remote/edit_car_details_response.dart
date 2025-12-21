class EditCarDetailsResponse {
  final int carId;
  final int customerId;
  final String vin;
  final String plateNumber;
  final String brand;
  final String model;
  final int modelYear;
  final String color;
  final String engineType;
  final int engineVolume;
  final String transmissionType;
  final int mileage;
  final DateTime updatedAt;
  final String bodyType;
  final String message;

  EditCarDetailsResponse({
    required this.carId,
    required this.customerId,
    required this.vin,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.modelYear,
    required this.color,
    required this.engineType,
    required this.engineVolume,
    required this.transmissionType,
    required this.mileage,
    required this.updatedAt,
    required this.bodyType,
    required this.message,
  });

  EditCarDetailsResponse copyWith({
    int? carId,
    int? customerId,
    String? vin,
    String? plateNumber,
    String? brand,
    String? model,
    int? modelYear,
    String? color,
    String? engineType,
    int? engineVolume,
    String? transmissionType,
    int? mileage,
    DateTime? updatedAt,
    String? bodyType,
    String? message,
  }) =>
      EditCarDetailsResponse(
        carId: carId ?? this.carId,
        customerId: customerId ?? this.customerId,
        vin: vin ?? this.vin,
        plateNumber: plateNumber ?? this.plateNumber,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        modelYear: modelYear ?? this.modelYear,
        color: color ?? this.color,
        engineType: engineType ?? this.engineType,
        engineVolume: engineVolume ?? this.engineVolume,
        transmissionType: transmissionType ?? this.transmissionType,
        mileage: mileage ?? this.mileage,
        updatedAt: updatedAt ?? this.updatedAt,
        bodyType: bodyType ?? this.bodyType,
        message: message ?? this.message,
      );

  factory EditCarDetailsResponse.fromJson(Map<String, dynamic> json) =>
      EditCarDetailsResponse(
        carId: json['carId'] as int,
        customerId: json['customerId'] as int,
        vin: json['vin'] as String,
        plateNumber: json['plateNumber'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        modelYear: json['modelYear'] as int,
        color: json['color'] as String,
        engineType: json['engineType'] as String,
        engineVolume: json['engineVolume'] as int,
        transmissionType: json['transmissionType'] as String,
        mileage: json['mileage'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        bodyType: json['bodyType'] as String,
        message: json['message'] as String,
      );

  Map<String, dynamic> toJson() => {
    'carId': carId,
    'customerId': customerId,
    'vin': vin,
    'plateNumber': plateNumber,
    'brand': brand,
    'model': model,
    'modelYear': modelYear,
    'color': color,
    'engineType': engineType,
    'engineVolume': engineVolume,
    'transmissionType': transmissionType,
    'mileage': mileage,
    'updatedAt': updatedAt.toIso8601String(),
    'bodyType': bodyType,
    'message': message,
  };
}