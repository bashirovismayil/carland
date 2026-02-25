import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/delete_notification_contractor.dart';
import '../../../utils/di/locator.dart';
import 'delete_notification_state.dart';

class DeleteNotificationCubit extends Cubit<DeleteNotificationState> {
  DeleteNotificationCubit() : super(DeleteNotificationInitial()) {
    _deleteNotificationRepo = locator<DeleteNotificationContractor>();
  }

  late final DeleteNotificationContractor _deleteNotificationRepo;

  Future<void> deleteNotification(int notificationId) async {
    try {
      emit(DeleteNotificationLoading());

      await _deleteNotificationRepo.deleteNotification(notificationId);

      log("Delete Notification Success: notificationId=$notificationId");
      emit(DeleteNotificationSuccess());
    } catch (e) {
      emit(DeleteNotificationError(e.toString()));
      log("Delete Notification Error: $e");
    }
  }
}