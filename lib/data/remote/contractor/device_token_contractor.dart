import '../models/remote/device_token_response.dart';

abstract class DeviceTokenContractor {
  Future<DeviceTokenResponse> sendDeviceToken(
      {required String deviceToken, required String platform});
}
