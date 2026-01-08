import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/privacy_policy_contractor.dart';
import '../../../utils/di/locator.dart';
import '../../data/remote/models/remote/privacy_policy_response.dart';
import 'privacy_policy_state.dart';

class PrivacyPolicyCubit extends Cubit<PrivacyPolicyState> {
  PrivacyPolicyCubit() : super(PrivacyPolicyInitial()) {
    _policyRepo = locator<PrivacyPolicyContractor>();
  }

  late final PrivacyPolicyContractor _policyRepo;

  Future<void> getPrivacyPolicy() async {
    try {
      emit(PrivacyPolicyLoading());

      final PolicyResponse policyData = await _policyRepo.getPrivacyPolicy();

      log("Get Privacy Policy Success");
      emit(PrivacyPolicySuccess(policyData));
    } catch (e) {
      emit(PrivacyPolicyError(e.toString()));
      log("Get Privacy Policy Error: $e");
    }
  }
}