import '../../../../data/remote/models/remote/get_model_list_response.dart';

sealed class GetCarModelListState {}

final class GetCarModelListInitial extends GetCarModelListState {}

final class GetCarModelListLoading extends GetCarModelListState {}

final class GetCarModelListSuccess extends GetCarModelListState {
  final List<ModelListResponse> models;
  GetCarModelListSuccess(this.models);
}

final class GetCarModelListError extends GetCarModelListState {
  final String message;
  GetCarModelListError(this.message);
}