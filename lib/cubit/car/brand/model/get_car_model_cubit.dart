import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/remote/contractor/model_list_contractor.dart';
import '../../../../utils/di/locator.dart';
import 'get_car_model_list_state.dart';

class GetCarModelListCubit extends Cubit<GetCarModelListState> {
  GetCarModelListCubit() : super(GetCarModelListInitial()) {
    _repo = locator<GetCarModelListContractor>();
  }

  late final GetCarModelListContractor _repo;

  Future<void> getModelList(int brandId) async {
    try {
      emit(GetCarModelListLoading());
      final models = await _repo.getModelList(brandId);
      log('[GetCarModelListCubit] Success: ${models.length} models for brandId: $brandId');
      emit(GetCarModelListSuccess(models));
    } catch (e) {
      log('[GetCarModelListCubit] Error: $e');
      emit(GetCarModelListError(e.toString()));
    }
  }
}