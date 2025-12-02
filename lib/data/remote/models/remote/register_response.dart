class RegisterResponse {
  final String? registerToken;
  final String? message;

  RegisterResponse({this.registerToken, this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        registerToken: json["registerToken"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "registerToken": registerToken,
    "message": message,
  };
}
