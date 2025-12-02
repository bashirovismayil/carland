class OtpVerifyResponse {
  final String? message;

  OtpVerifyResponse({this.message});

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) =>
      OtpVerifyResponse(message: json['message']);

  Map<String, dynamic> toJson() => {
    'message': message,
  };
}
