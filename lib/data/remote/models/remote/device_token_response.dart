class DeviceTokenResponse {
  final String? message;

  DeviceTokenResponse({
    this.message,
  });

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) =>
      DeviceTokenResponse(
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {'message': message};
}
