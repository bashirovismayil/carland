class SendFeedbackResponse {
  final String message;
  final String estimatedResponseTime;
  final int ticketId;

  SendFeedbackResponse({
    required this.message,
    required this.estimatedResponseTime,
    required this.ticketId,
  });

  SendFeedbackResponse copyWith({
    String? message,
    String? estimatedResponseTime,
    int? ticketId,
  }) =>
      SendFeedbackResponse(
        message: message ?? this.message,
        estimatedResponseTime: estimatedResponseTime ?? this.estimatedResponseTime,
        ticketId: ticketId ?? this.ticketId,
      );

  factory SendFeedbackResponse.fromJson(Map<String, dynamic> json) =>
      SendFeedbackResponse(
        message: json['message'] as String,
        estimatedResponseTime: json['estimatedResponseTime'] as String,
        ticketId: json['ticketId'] as int,
      );
}