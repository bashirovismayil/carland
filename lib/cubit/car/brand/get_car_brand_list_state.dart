import '../../../data/remote/models/remote/get_brand_list_response.dart';

sealed class GetCarBrandListState {}

final class GetCarBrandListInitial extends GetCarBrandListState {}

final class GetCarBrandListLoading extends GetCarBrandListState {}

final class GetCarBrandListSuccess extends GetCarBrandListState {
  final List<BrandListResponse> brands;
  GetCarBrandListSuccess(this.brands);
}

final class GetCarBrandListError extends GetCarBrandListState {
  final String message;
  GetCarBrandListError(this.message);
}