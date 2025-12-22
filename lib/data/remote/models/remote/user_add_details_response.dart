
class UserAddDetailsResponse {
  final String message;

  UserAddDetailsResponse({
    required this.message,
  });

  UserAddDetailsResponse copyWith({
    String? message,
  }) =>
      UserAddDetailsResponse(
        message: message ?? this.message,
      );

  factory UserAddDetailsResponse.fromJson(Map<String, dynamic> json) =>
      UserAddDetailsResponse(
        message: json['message'] as String? ?? 'Details added successfully',
      );

  Map<String, dynamic> toJson() => {
    'message': message,
  };
}