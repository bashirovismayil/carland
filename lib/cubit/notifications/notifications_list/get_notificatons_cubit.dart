import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_notifications_list_contractor.dart';
import '../../../utils/di/locator.dart';
import 'get_notifications_state.dart';

class GetNotificationListCubit extends Cubit<GetNotificationListState> {
  GetNotificationListCubit() : super(GetNotificationListInitial()) {
    _notificationRepo = locator<GetNotificationListContractor>();
  }

  late final GetNotificationListContractor _notificationRepo;

  Future<void> getNotificationList() async {
    try {
      emit(GetNotificationListLoading());

      final notifications = await _notificationRepo.getNotificationList();

      log("Get Notification List Success: ${notifications.length} notifications found");
      emit(GetNotificationListSuccess(notifications));
    } catch (e) {
      emit(GetNotificationListError(e.toString()));
      log("Get Notification List Error: $e");
    }
  }
  void updateNotificationReadStatus(int notificationId, bool read) {
    final currentState = state;
    if (currentState is GetNotificationListSuccess) {
      final updatedList = currentState.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(read: read);
        }
        return n;
      }).toList();

      emit(GetNotificationListSuccess(updatedList));
    }
  }

  void removeNotification(int notificationId) {
    final currentState = state;
    if (currentState is GetNotificationListSuccess) {
      final updatedList = currentState.notifications
          .where((n) => n.id != notificationId)
          .toList();

      emit(GetNotificationListSuccess(updatedList));
    }
  }

  void markAllAsRead() {
    final currentState = state;
    if (currentState is GetNotificationListSuccess) {
      final updatedList = currentState.notifications
          .map((n) => n.copyWith(read: true))
          .toList();

      emit(GetNotificationListSuccess(updatedList));
    }
  }
}