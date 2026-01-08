import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/di/locator.dart';
import '../../data/remote/contractor/terms_and_conditions_contractor.dart';
import '../../data/remote/models/remote/terms_conditions_response.dart';
import 'terms_conditions_state.dart';

class TermsConditionsCubit extends Cubit<TermsConditionsState> {
  TermsConditionsCubit() : super(TermsConditionsInitial()) {
    _termsRepo = locator<TermsConditionsContractor>();
  }

  late final TermsConditionsContractor _termsRepo;

  Future<void> getTermsConditions() async {
    try {
      emit(TermsConditionsLoading());

      final TermsConditionsResponse termsData =
      await _termsRepo.getTermsConditions();

      log("Get Terms & Conditions Success");
      emit(TermsConditionsSuccess(termsData));
    } catch (e) {
      emit(TermsConditionsError(e.toString()));
      log("Get Terms & Conditions Error: $e");
    }
  }
}