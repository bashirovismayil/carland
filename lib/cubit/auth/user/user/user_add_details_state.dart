import '../../../../data/remote/models/remote/user_add_details_response.dart';

sealed class UserAddDetailsState {}

final class UserAddDetailsInitial extends UserAddDetailsState {}

final class UserAddDetailsLoading extends UserAddDetailsState {}

final class UserAddDetailsSuccess extends UserAddDetailsState {
  final UserAddDetailsResponse response;
  UserAddDetailsSuccess(this.response);
}

final class UserAddDetailsError extends UserAddDetailsState {
  final String message;
  UserAddDetailsError(this.message);
}