import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/get_color_list_contractor.dart';
import '../../../utils/di/locator.dart';
import '../../data/remote/models/remote/get_color_list_response.dart';
import 'get_color_list_state.dart';

class GetColorListCubit extends Cubit<GetColorListState> {
  GetColorListCubit() : super(GetColorListInitial()) {
    _colorRepo = locator<GetColorListContractor>();
  }

  late final GetColorListContractor _colorRepo;

  Future<void> getColorList() async {
    try {
      emit(GetColorListLoading());

      final List<GetColorListResponse> colors = await _colorRepo.getColorList();

      log("Get Color List Success: ${colors.length} colors loaded");
      emit(GetColorListSuccess(colors));
    } catch (e) {
      emit(GetColorListError(e.toString()));
      log("Get Color List Error: $e");
    }
  }
}