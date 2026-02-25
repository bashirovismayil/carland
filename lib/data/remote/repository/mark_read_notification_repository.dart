import '../contractor/mark_read_notification_contractor.dart';
import '../services/remote/mark_read_notification_service.dart';

class MarkNotificationAsReadRepository implements MarkNotificationAsReadContractor {
  MarkNotificationAsReadRepository(this._service);

  final MarkNotificationAsReadService _service;

  @override
  Future<void> markNotificationAsRead(int notificationId, bool setRead) {
    return _service.markNotificationAsRead(notificationId, setRead);
  }
}