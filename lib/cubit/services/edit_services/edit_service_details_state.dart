import '../../../data/remote/models/remote/edit_services_details_response.dart';

sealed class EditCarServicesState {}

final class EditCarServicesInitial extends EditCarServicesState {}

final class EditCarServicesLoading extends EditCarServicesState {}

final class EditCarServicesSuccess extends EditCarServicesState {
  final EditCarServicesResponse response;
  EditCarServicesSuccess(this.response);
}

final class EditCarServicesError extends EditCarServicesState {
  final String message;
  EditCarServicesError(this.message);
}