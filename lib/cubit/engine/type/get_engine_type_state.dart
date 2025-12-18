import '../../../data/remote/models/remote/get_engine_type_response.dart';

sealed class GetEngineTypeListState {}
final class GetEngineTypeListInitial extends GetEngineTypeListState {}
final class GetEngineTypeListLoading extends GetEngineTypeListState {}
final class GetEngineTypeListSuccess extends GetEngineTypeListState {
  final List<GetEngineTypeListResponse> engineTypes;
  GetEngineTypeListSuccess(this.engineTypes);
}
final class GetEngineTypeListError extends GetEngineTypeListState {
  final String message;
  GetEngineTypeListError(this.message);
}