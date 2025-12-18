import '../../../data/remote/models/remote/get_body_type_response.dart';

sealed class GetBodyTypeListState {}

final class GetBodyTypeListInitial extends GetBodyTypeListState {}

final class GetBodyTypeListLoading extends GetBodyTypeListState {}

final class GetBodyTypeListSuccess extends GetBodyTypeListState {
  final List<GetBodyTypeListResponse> bodyTypes;
  GetBodyTypeListSuccess(this.bodyTypes);
}

final class GetBodyTypeListError extends GetBodyTypeListState {
  final String message;
  GetBodyTypeListError(this.message);
}