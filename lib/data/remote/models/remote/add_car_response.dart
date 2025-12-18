class AddCarResponse {
  final int? carId;
  final int? customerId;
  final String? vin;
  final String? plateNumber;
  final String? brand;
  final String? model;
  final int? modelYear;
  final String? color;
  final String? engineType;
  final int? engineVolume;
  final String? transmissionType;
  final int? mileage;
  final String? updatedAt;
  final String? bodyType;
  final String? message;

  AddCarResponse({
    this.carId,
    this.customerId,
    this.vin,
    this.plateNumber,
    this.brand,
    this.model,
    this.modelYear,
    this.color,
    this.engineType,
    this.engineVolume,
    this.transmissionType,
    this.mileage,
    this.updatedAt,
    this.bodyType,
    this.message,
  });

  factory AddCarResponse.fromJson(Map<String, dynamic> json) => AddCarResponse(
    carId: json['carId'] as int?,
    customerId: json['customerId'] as int?,
    vin: json['vin'] as String?,
    plateNumber: json['plateNumber'] as String?,
    brand: json['brand'] as String?,
    model: json['model'] as String?,
    modelYear: json['modelYear'] as int?,
    color: json['color'] as String?,
    engineType: json['engineType'] as String?,
    engineVolume: json['engineVolume'] as int?,
    transmissionType: json['transmissionType'] as String?,
    mileage: json['mileage'] as int?,
    updatedAt: json['updatedAt'] as String?,
    bodyType: json['bodyType'] as String?,
    message: json['message'] as String?,
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
    'updatedAt': updatedAt,
    'bodyType': bodyType,
    'message': message,
  };
}