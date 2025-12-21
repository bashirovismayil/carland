import '../../../data/remote/models/remote/get_car_services_response.dart';

sealed class GetCarServicesState {}

final class GetCarServicesInitial extends GetCarServicesState {}

final class GetCarServicesLoading extends GetCarServicesState {}

final class GetCarServicesSuccess extends GetCarServicesState {
  final GetCarServicesResponse servicesData;
  GetCarServicesSuccess(this.servicesData);
}

final class GetCarServicesError extends GetCarServicesState {
  final String message;
  GetCarServicesError(this.message);
}