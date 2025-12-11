import '../../data/remote/models/remote/get_color_list_response.dart';

sealed class GetColorListState {}

final class GetColorListInitial extends GetColorListState {}

final class GetColorListLoading extends GetColorListState {}

final class GetColorListSuccess extends GetColorListState {
  final List<GetColorListResponse> colors;
  GetColorListSuccess(this.colors);
}

final class GetColorListError extends GetColorListState {
  final String message;
  GetColorListError(this.message);
}