import '../../../data/remote/models/remote/get_year_list_response.dart';

sealed class GetYearListState {}

final class GetYearListInitial extends GetYearListState {}

final class GetYearListLoading extends GetYearListState {}

final class GetYearListSuccess extends GetYearListState {
  final List<GetYearListResponse> years;
  GetYearListSuccess(this.years);
}

final class GetYearListError extends GetYearListState {
  final String message;
  GetYearListError(this.message);
}