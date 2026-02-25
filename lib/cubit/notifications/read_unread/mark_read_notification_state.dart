sealed class MarkNotificationAsReadState {}

final class MarkNotificationAsReadInitial extends MarkNotificationAsReadState {}

final class MarkNotificationAsReadLoading extends MarkNotificationAsReadState {}

final class MarkNotificationAsReadSuccess extends MarkNotificationAsReadState {}

final class MarkNotificationAsReadError extends MarkNotificationAsReadState {
  final String message;
  MarkNotificationAsReadError(this.message);
}