
sealed class SetupPassState {}

final class SetupPassInitial extends SetupPassState {}

final class SetupPassLoading extends SetupPassState {}

final class SetupPassSuccess extends SetupPassState {
  final String message;
  SetupPassSuccess(this.message);
}

final class SetupPassError extends SetupPassState {
  final String message;
  SetupPassError(this.message);
}
