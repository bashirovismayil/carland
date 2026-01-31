import '../../data/remote/models/remote/send_feedback_response.dart';

sealed class FeedbackState {}

final class FeedbackInitial extends FeedbackState {}

final class FeedbackLoading extends FeedbackState {}

final class FeedbackTypesLoaded extends FeedbackState {
  final List<String> types;
  FeedbackTypesLoaded(this.types);
}

final class FeedbackSuccess extends FeedbackState {
  final SendFeedbackResponse response;
  FeedbackSuccess(this.response);
}

final class FeedbackError extends FeedbackState {
  final String message;
  FeedbackError(this.message);
}