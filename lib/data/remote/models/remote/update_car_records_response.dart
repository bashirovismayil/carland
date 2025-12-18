class UpdateCarRecordResponse {
  final String? message;
  final bool success;

  UpdateCarRecordResponse({
    this.message,
    required this.success,
  });

  factory UpdateCarRecordResponse.fromJson(Map<String, dynamic> json) =>
      UpdateCarRecordResponse(
        message: json['message'] as String?,
        success: json['success'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
  };
}