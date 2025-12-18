import '../../../data/remote/models/remote/add_car_response.dart';

sealed class AddCarState {}

final class AddCarInitial extends AddCarState {}

final class AddCarLoading extends AddCarState {}

final class AddCarSuccess extends AddCarState {
  final AddCarResponse response;
  AddCarSuccess(this.response);
}

final class AddCarError extends AddCarState {
  final String message;
  AddCarError(this.message);
}
