sealed class ExecuteCarServiceState {}

final class ExecuteCarServiceInitial extends ExecuteCarServiceState {}

final class ExecuteCarServiceLoading extends ExecuteCarServiceState {}

final class ExecuteCarServiceSuccess extends ExecuteCarServiceState {
  final String message;
  ExecuteCarServiceSuccess(this.message);
}

final class ExecuteCarServiceError extends ExecuteCarServiceState {
  final String message;
  ExecuteCarServiceError(this.message);
}