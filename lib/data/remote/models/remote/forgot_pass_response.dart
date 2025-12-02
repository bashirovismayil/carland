class ForgotPasswordResponse {
  final String message;
  final String registerToken;

  ForgotPasswordResponse({
    required this.message,
    required this.registerToken,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponse(
        message: json['message'],
        registerToken: json['registerToken'],
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'registerToken': registerToken,
  };
}