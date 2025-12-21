import '../../data/remote/models/remote/edit_car_details_response.dart';

sealed class EditCarDetailsState {}

final class EditCarDetailsInitial extends EditCarDetailsState {}

final class EditCarDetailsLoading extends EditCarDetailsState {}

final class EditCarDetailsSuccess extends EditCarDetailsState {
  final EditCarDetailsResponse response;
  EditCarDetailsSuccess(this.response);
}

final class EditCarDetailsError extends EditCarDetailsState {
  final String message;
  EditCarDetailsError(this.message);
}