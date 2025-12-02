import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../data/remote/contractor/device_token_contractor.dart';
import '../../../utils/di/locator.dart';
import 'device_token_state.dart';

class DeviceTokenCubit extends Cubit<DeviceTokenState> {
  DeviceTokenCubit() : super(DeviceTokenInitial()) {
    _repo = locator<DeviceTokenContractor>();
  }

  late final DeviceTokenContractor _repo;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> registerDeviceToken() async {
    try {
      emit(DeviceTokenLoading());

      final fcmToken = await _firebaseMessaging.getToken();

      if (fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }

      log('FCM Token: $fcmToken');

      final platform = Platform.isAndroid ? 'android' : 'ios';

      final response = await _repo.sendDeviceToken(
        deviceToken: fcmToken,
        platform: platform,
      );

      emit(DeviceTokenSuccess(response.message));
      log('Device token registered successfully: ${response.message}');
    } catch (e) {
      emit(DeviceTokenError(e.toString()));
      log('Device token registration error: $e');
    }
  }

  void listenToTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      log('FCM Token refreshed: $newToken');
      registerDeviceToken();
    });
  }
}