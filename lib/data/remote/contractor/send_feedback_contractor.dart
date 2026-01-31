import '../models/remote/send_feedback_response.dart';

abstract class FeedbackContractor {
  Future<List<String>> getFeedbackTypes();

  Future<SendFeedbackResponse> sendFeedback({
    required String type,
    required String subject,
    required String description,
    int? rating,
    String? filePath,
  });
}