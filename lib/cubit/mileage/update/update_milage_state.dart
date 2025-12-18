
import '../../../data/remote/models/remote/update_car_mileage_response.dart';

sealed class UpdateCarMileageState {}

final class UpdateCarMileageInitial extends UpdateCarMileageState {}

final class UpdateCarMileageLoading extends UpdateCarMileageState {}

final class UpdateCarMileageSuccess extends UpdateCarMileageState {
  final UpdateCarMileageResponse response;
  UpdateCarMileageSuccess(this.response);
}

final class UpdateCarMileageError extends UpdateCarMileageState {
  final String message;
  UpdateCarMileageError(this.message);
}
