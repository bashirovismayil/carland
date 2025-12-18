import '../../../data/remote/models/remote/GetCarRecordsResponse.dart';

sealed class GetCarRecordsState {}

final class GetCarRecordsInitial extends GetCarRecordsState {}

final class GetCarRecordsLoading extends GetCarRecordsState {}

final class GetCarRecordsSuccess extends GetCarRecordsState {
  final List<GetCarRecordsResponse> records;
  GetCarRecordsSuccess(this.records);
}

final class GetCarRecordsError extends GetCarRecordsState {
  final String message;
  GetCarRecordsError(this.message);
}