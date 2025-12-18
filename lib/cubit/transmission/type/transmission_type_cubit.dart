import 'dart:developer';

import 'package:carcat/cubit/transmission/type/tranmission_type_state.dart';
import 'package:carcat/data/remote/contractor/get_transmission_type_contractor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/di/locator.dart';

class GetTransmissionListCubit extends Cubit<GetTransmissionListState> {
  GetTransmissionListCubit() : super(GetTransmissionListInitial()) {
    _repo = locator<GetTransmissionTypeContractor>();
  }

  late final GetTransmissionTypeContractor _repo;

  Future<void> getTransmissionList() async {
    try {
      emit(GetTransmissionListLoading());
      final data = await _repo.getTransmissionTypeList();
      log("Get Transmission List Success: ${data.length} items");
      emit(GetTransmissionListSuccess(data));
    } catch (e) {
      emit(GetTransmissionListError(e.toString()));
      log("Get Transmission List Error: $e");
    }
  }
}