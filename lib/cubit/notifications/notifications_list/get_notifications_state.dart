import '../../../data/remote/models/remote/get_notifications_list_response.dart';

sealed class GetNotificationListState {}

final class GetNotificationListInitial extends GetNotificationListState {}

final class GetNotificationListLoading extends GetNotificationListState {}

final class GetNotificationListSuccess extends GetNotificationListState {
  final List<GetNotificationListResponse> notifications;
  GetNotificationListSuccess(this.notifications);
}

final class GetNotificationListError extends GetNotificationListState {
  final String message;
  GetNotificationListError(this.message);
}