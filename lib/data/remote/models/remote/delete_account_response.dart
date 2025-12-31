class DeleteAccountResponse {
  final String message;
  final bool success;

  DeleteAccountResponse({
    required this.message,
    required this.success,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) =>
      DeleteAccountResponse(
        message: json['message'] as String? ?? '',
        success: json['success'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
  };
}