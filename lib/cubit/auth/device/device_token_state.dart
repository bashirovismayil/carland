abstract class DeviceTokenState {}

class DeviceTokenInitial extends DeviceTokenState {}

class DeviceTokenLoading extends DeviceTokenState {}

class DeviceTokenSuccess extends DeviceTokenState {
  final String? message;
  DeviceTokenSuccess(this.message);
}

class DeviceTokenError extends DeviceTokenState {
  final String? message;
  DeviceTokenError(this.message);
}