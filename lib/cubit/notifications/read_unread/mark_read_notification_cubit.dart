import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/mark_read_notification_contractor.dart';
import '../../../utils/di/locator.dart';
import 'mark_read_notification_state.dart';

class MarkNotificationAsReadCubit extends Cubit<MarkNotificationAsReadState> {
  MarkNotificationAsReadCubit() : super(MarkNotificationAsReadInitial()) {
    _markAsReadRepo = locator<MarkNotificationAsReadContractor>();
  }

  late final MarkNotificationAsReadContractor _markAsReadRepo;

  Future<void> markNotificationAsRead(int notificationId, bool setRead) async {
    try {
      emit(MarkNotificationAsReadLoading());

      await _markAsReadRepo.markNotificationAsRead(notificationId, setRead);

      log("Mark Notification As Read Success: notificationId=$notificationId, setRead=$setRead");
      emit(MarkNotificationAsReadSuccess());
    } catch (e) {
      emit(MarkNotificationAsReadError(e.toString()));
      log("Mark Notification As Read Error: $e");
    }
  }
}