
import 'package:carcat/cubit/feedback/send_feedback_cubit.dart';

abstract class FeedbackState {
  const FeedbackState();

  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackTypesLoaded extends FeedbackState {
  final List<String> types;

  const FeedbackTypesLoaded(this.types);

  @override
  List<Object?> get props => [types];
}

class FeedbackSuccess extends FeedbackState {
  final String message;

  const FeedbackSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Yeni validation state
class FeedbackValidationFailed extends FeedbackState {
  final FeedbackValidationError error;

  const FeedbackValidationFailed(this.error);

  @override
  List<Object?> get props => [error];
}