import '../../../data/remote/models/remote/check_vin_response.dart';

sealed class CheckVinState {}

final class CheckVinInitial extends CheckVinState {}

final class CheckVinLoading extends CheckVinState {}

final class CheckVinSuccess extends CheckVinState {
  final CheckVinResponse carData;
  CheckVinSuccess(this.carData);
}

final class CheckVinError extends CheckVinState {
  final String message;
  CheckVinError(this.message);
}