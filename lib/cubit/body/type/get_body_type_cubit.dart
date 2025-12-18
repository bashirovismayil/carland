import 'dart:developer';

import 'package:carcat/data/remote/contractor/get_body_type_contractor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/di/locator.dart';
import 'get_body_type_state.dart';

class GetBodyTypeListCubit extends Cubit<GetBodyTypeListState> {
  GetBodyTypeListCubit() : super(GetBodyTypeListInitial()) {
    _repo = locator<GetBodyTypeContractor>();
  }

  late final GetBodyTypeContractor _repo;

  Future<void> getBodyTypeList() async {
    try {
      emit(GetBodyTypeListLoading());
      final data = await _repo.getBodyTypeList();
      log("Get Body Type List Success: ${data.length} items");
      emit(GetBodyTypeListSuccess(data));
    } catch (e) {
      emit(GetBodyTypeListError(e.toString()));
      log("Get Body Type List Error: $e");
    }
  }
}