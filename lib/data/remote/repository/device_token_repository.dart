import '../contractor/device_token_contractor.dart';
import '../models/remote/device_token_response.dart';
import '../services/remote/device_token_service.dart';

class DeviceTokenRepository implements DeviceTokenContractor {
  DeviceTokenRepository(this._service);

  final DeviceTokenService _service;

  @override
  Future<DeviceTokenResponse> sendDeviceToken({
    required String deviceToken,
    required String platform,
  }) {
    return _service.sendDeviceToken(
        deviceToken: deviceToken, platform: platform);
  }
}
