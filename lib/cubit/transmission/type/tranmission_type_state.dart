import 'package:carcat/data/remote/models/remote/get_transmission_type_response.dart';

sealed class GetTransmissionListState {}

final class GetTransmissionListInitial extends GetTransmissionListState {}

final class GetTransmissionListLoading extends GetTransmissionListState {}

final class GetTransmissionListSuccess extends GetTransmissionListState {
  final List<GetTransmissionTypeListResponse> transmissions;
  GetTransmissionListSuccess(this.transmissions);
}

final class GetTransmissionListError extends GetTransmissionListState {
  final String message;
  GetTransmissionListError(this.message);
}