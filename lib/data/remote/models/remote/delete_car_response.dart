class DeleteCarResponse {
  final String message;

  DeleteCarResponse({
    required this.message,
  });

  DeleteCarResponse copyWith({
    String? message,
  }) =>
      DeleteCarResponse(
        message: message ?? this.message,
      );

  factory DeleteCarResponse.fromJson(Map<String, dynamic> json) =>
      DeleteCarResponse(
        message: json['message'] as String? ?? 'Car deleted successfully',
      );

  Map<String, dynamic> toJson() => {
    'message': message,
  };
}