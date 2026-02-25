import '../contractor/delete_notification_contractor.dart';
import '../services/remote/delete_notification_service.dart';

class DeleteNotificationRepository implements DeleteNotificationContractor {
  DeleteNotificationRepository(this._service);

  final DeleteNotificationService _service;

  @override
  Future<void> deleteNotification(int notificationId) {
    return _service.deleteNotification(notificationId);
  }
}