import '../contractor/send_feedback_contractor.dart';
import '../models/remote/send_feedback_response.dart';
import '../services/remote/send_feedback_service.dart';

class FeedbackRepository implements FeedbackContractor {
  final FeedbackService _service;

  FeedbackRepository(this._service);

  @override
  Future<List<String>> getFeedbackTypes() {
    return _service.getFeedbackTypes();
  }

  @override
  Future<SendFeedbackResponse> sendFeedback({
    required String type,
    required String subject,
    required String description,
    int? rating,
    String? filePath,
  }) {
    return _service.sendFeedback(
      type: type,
      subject: subject,
      description: description,
      rating: rating,
      filePath: filePath,
    );
  }
}