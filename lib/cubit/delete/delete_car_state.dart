import '../../data/remote/models/remote/delete_car_response.dart';

sealed class DeleteCarState {}

final class DeleteCarInitial extends DeleteCarState {}

final class DeleteCarLoading extends DeleteCarState {}

final class DeleteCarSuccess extends DeleteCarState {
  final DeleteCarResponse response;
  DeleteCarSuccess(this.response);
}

final class DeleteCarError extends DeleteCarState {
  final String message;
  DeleteCarError(this.message);
}