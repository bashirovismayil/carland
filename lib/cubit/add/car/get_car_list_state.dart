import '../../../data/remote/models/remote/get_car_list_response.dart';

sealed class GetCarListState {}

final class GetCarListInitial extends GetCarListState {}

final class GetCarListLoading extends GetCarListState {}

final class GetCarListSuccess extends GetCarListState {
  final List<GetCarListResponse> carList;
  GetCarListSuccess(this.carList);
}

final class GetCarListError extends GetCarListState {
  final String message;
  GetCarListError(this.message);
}