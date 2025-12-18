class UpdateCarMileageResponse {
  final String vin;
  final int mileage;

  UpdateCarMileageResponse({
    required this.vin,
    required this.mileage,
  });

  factory UpdateCarMileageResponse.fromJson(Map<String, dynamic> json) =>
      UpdateCarMileageResponse(
        vin: json['vin'] as String,
        mileage: json['mileage'] as int,
      );

  Map<String, dynamic> toJson() => {
    'vin': vin,
    'mileage': mileage,
  };
}