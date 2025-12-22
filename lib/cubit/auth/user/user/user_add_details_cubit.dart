import 'dart:developer';
import 'package:carcat/cubit/auth/user/user/user_add_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/remote/contractor/user_add_details_contractor.dart';
import '../../../../data/remote/models/remote/user_add_details_response.dart';
import '../../../../utils/di/locator.dart';

class UserAddDetailsCubit extends Cubit<UserAddDetailsState> {
  UserAddDetailsCubit() : super(UserAddDetailsInitial()) {
    _detailsRepo = locator<UserAddDetailsContractor>();
  }

  late final UserAddDetailsContractor _detailsRepo;

  Future<UserAddDetailsResponse> addUserDetails() async {
    try {
      emit(UserAddDetailsLoading());

      final UserAddDetailsResponse response = await _detailsRepo.addUserDetails();

      log("✅ Add User Details Success: ${response.toJson()}");
      emit(UserAddDetailsSuccess(response));

      return response;
    } catch (e) {
      emit(UserAddDetailsError(e.toString()));
      log("❌ Add User Details Error: $e");
      rethrow;
    }
  }
}