import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';  // <-- bu import əlavə et
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_notifications_list_contractor.dart';
import '../../../data/remote/models/remote/get_notifications_list_response.dart';  // <-- bu import əlavə et
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
      final sorted = [...notifications]..sort((a, b) => b.id.compareTo(a.id));
      log("Get Notification List Success: ${sorted.length} notifications found");
      emit(GetNotificationListSuccess(sorted));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        emit(GetNotificationListSuccess([]));
      } else {
        emit(GetNotificationListError(e.toString()));
      }
      log("Get Notification List Error: $e");
    }
  }

  void addNotificationFromPush(RemoteMessage message) {
    final currentState = state;
    final data = message.data;

    final newNotification = GetNotificationListResponse(
      id: int.tryParse(data['id']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
      created: data['created'] != null
          ? DateTime.tryParse(data['created']) ?? DateTime.now()
          : DateTime.now(),
      type: data['type'] ?? 'general',
      notificationText: data['notificationText'] ?? message.notification?.body ?? '',
      title: data['title'] ?? message.notification?.title ?? '',
      customerId: int.tryParse(data['customerId']?.toString() ?? '') ?? 0,
      status: data['status'] ?? 'active',
      read: false,
    );

    if (currentState is GetNotificationListSuccess) {
      final updatedList = [newNotification, ...currentState.notifications];
      emit(GetNotificationListSuccess(updatedList));
    } else {
      emit(GetNotificationListSuccess([newNotification]));
    }
  }
  void updateNotificationReadStatus(int notificationId, bool read) {
    final currentState = state;
    if (currentState is GetNotificationListSuccess) {
      final updatedList = currentState.notifications.map((n) {
        if (n.id == notificationId) return n.copyWith(read: read);
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