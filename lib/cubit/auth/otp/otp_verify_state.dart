part of 'otp_verify_cubit.dart';

sealed class OtpVerifyState {}

final class OtpVerifyInitial extends OtpVerifyState {}

final class OtpVerifying extends OtpVerifyState {}

final class OtpVerifySuccess extends OtpVerifyState {
  final String? message;
  OtpVerifySuccess(this.message);
}

final class OtpVerifyError extends OtpVerifyState {
  final String message;
  OtpVerifyError(this.message);
}
