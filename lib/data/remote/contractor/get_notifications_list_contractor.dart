import '../models/remote/get_notifications_list_response.dart';

abstract class GetNotificationListContractor {
  Future<List<GetNotificationListResponse>> getNotificationList();
}