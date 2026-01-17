class CheckVinResponse {
  final String? carId;
  final String? customerId;
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
  final List<String>? vinProvidedFields;

  CheckVinResponse({
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
    this.vinProvidedFields,
  });

  CheckVinResponse copyWith({
    String? carId,
    String? customerId,
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
    String? updatedAt,
    String? bodyType,
    String? message,
    List<String>? vinProvidedFields,
  }) {
    return CheckVinResponse(
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
      vinProvidedFields: vinProvidedFields ?? this.vinProvidedFields,
    );
  }

  factory CheckVinResponse.fromJson(Map<String, dynamic> json) =>
      CheckVinResponse(
        carId: json['carId'] as String?,
        customerId: json['customerId'] as String?,
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
        vinProvidedFields: (json['vinProvidedFields'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
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
    'vinProvidedFields': vinProvidedFields,
  };
}