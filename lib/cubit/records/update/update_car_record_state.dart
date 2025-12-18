import '../../../data/remote/models/remote/update_car_records_response.dart';

sealed class UpdateCarRecordState {}

final class UpdateCarRecordInitial extends UpdateCarRecordState {}

final class UpdateCarRecordLoading extends UpdateCarRecordState {
  final int recordId;
  UpdateCarRecordLoading(this.recordId);
}

final class UpdateCarRecordSuccess extends UpdateCarRecordState {
  final int recordId;
  final UpdateCarRecordResponse response;
  UpdateCarRecordSuccess(this.recordId, this.response);
}

final class UpdateCarRecordError extends UpdateCarRecordState {
  final int recordId;
  final String message;
  UpdateCarRecordError(this.recordId, this.message);
}
