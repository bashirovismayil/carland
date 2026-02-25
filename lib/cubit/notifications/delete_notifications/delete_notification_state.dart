sealed class DeleteNotificationState {}

final class DeleteNotificationInitial extends DeleteNotificationState {}

final class DeleteNotificationLoading extends DeleteNotificationState {}

final class DeleteNotificationSuccess extends DeleteNotificationState {}

final class DeleteNotificationError extends DeleteNotificationState {
  final String message;
  DeleteNotificationError(this.message);
}