import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/brand_list_contractor.dart';
import '../../../data/remote/models/remote/get_brand_list_response.dart';
import '../../../utils/di/locator.dart';
import 'get_car_brand_list_state.dart';

class GetCarBrandListCubit extends Cubit<GetCarBrandListState> {
  GetCarBrandListCubit() : super(GetCarBrandListInitial()) {
    _repo = locator<GetCarBrandListContractor>();
  }

  late final GetCarBrandListContractor _repo;

  Future<void> getBrandList() async {
    try {
      emit(GetCarBrandListLoading());
      final brands = await _repo.getBrandList();
      log('[GetCarBrandListCubit] Success: ${brands.length} brands');
      emit(GetCarBrandListSuccess(brands));
    } catch (e) {
      log('[GetCarBrandListCubit] Error: $e');
      emit(GetCarBrandListError(e.toString()));
    }
  }

  int? resolveBrandId(String brandName, List<BrandListResponse> brands) {
    try {
      final match = brands.firstWhere(
            (b) => b.brandName?.toLowerCase() == brandName.toLowerCase(),
      );
      return match.brandId;
    } catch (_) {
      return null;
    }
  }
}