part of 'otp_send_cubit.dart';

sealed class OtpSendState {}

final class OtpSendInitial extends OtpSendState {}

final class OtpSending extends OtpSendState {}

final class OtpSendSuccess extends OtpSendState {
  final String? message;
  OtpSendSuccess(this.message);
}

final class OtpSendError extends OtpSendState {
  final String message;
  OtpSendError(this.message);
}
