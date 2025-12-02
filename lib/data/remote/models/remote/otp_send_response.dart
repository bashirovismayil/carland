class OtpSendResponse {
  final String? message;

  OtpSendResponse({this.message});

  factory OtpSendResponse.fromJson(Map<String, dynamic> json) =>
      OtpSendResponse(message: json['message']);

  Map<String, dynamic> toJson() => {
    'message': message,
  };
}
