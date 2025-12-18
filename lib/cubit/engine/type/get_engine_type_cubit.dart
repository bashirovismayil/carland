import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_engine_type_contractor.dart';
import '../../../utils/di/locator.dart';
import 'get_engine_type_state.dart';

class GetEngineTypeListCubit extends Cubit<GetEngineTypeListState> {
  GetEngineTypeListCubit() : super(GetEngineTypeListInitial()) {
    _repo = locator<GetEngineTypeListContractor>();
  }

  late final GetEngineTypeListContractor _repo;

  Future<void> getEngineTypeList() async {
    try {
      emit(GetEngineTypeListLoading());
      final data = await _repo.getEngineTypeList();
      log("Get Engine Type List Success: ${data.length} items");
      emit(GetEngineTypeListSuccess(data));
    } catch (e) {
      emit(GetEngineTypeListError(e.toString()));
      log("Get Engine Type List Error: $e");
    }
  }
}