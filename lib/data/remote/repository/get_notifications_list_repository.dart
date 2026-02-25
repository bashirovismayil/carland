import '../contractor/get_notifications_list_contractor.dart';
import '../models/remote/get_notifications_list_response.dart';
import '../services/remote/get_notifications_list_service.dart';

class GetNotificationListRepository implements GetNotificationListContractor {
  GetNotificationListRepository(this._service);

  final GetNotificationListService _service;

  @override
  Future<List<GetNotificationListResponse>> getNotificationList() {
    return _service.getNotificationList();
  }
}