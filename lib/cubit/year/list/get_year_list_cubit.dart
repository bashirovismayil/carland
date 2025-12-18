import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_year_list_contractor.dart';
import '../../../utils/di/locator.dart';
import 'get_year_list_state.dart';

class GetYearListCubit extends Cubit<GetYearListState> {
  GetYearListCubit() : super(GetYearListInitial()) {
    _repo = locator<GetYearListContractor>();
  }

  late final GetYearListContractor _repo;

  Future<void> getYearList() async {
    try {
      emit(GetYearListLoading());
      final data = await _repo.getYearList();
      log("Get Year List Success: ${data.length} items");
      emit(GetYearListSuccess(data));
    } catch (e) {
      emit(GetYearListError(e.toString()));
      log("Get Year List Error: $e");
    }
  }
}