part of 'register_cubit.dart';

sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  // RegisterSuccess(this.response);
  // final RegisterResponse response;
}

final class RegisterError extends RegisterState {
  RegisterError(this.message);

  final String message;
}

final class RegisterNetworkError extends RegisterState {
  RegisterNetworkError(this.message);

  final String message;
}
