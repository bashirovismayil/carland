class SetPassResponse {
  final String message;

  SetPassResponse({required this.message});

  factory SetPassResponse.fromJson(Map<String, dynamic> json) =>
      SetPassResponse(message: json['message']);

  Map<String, dynamic> toJson() => {'message': message};
}
