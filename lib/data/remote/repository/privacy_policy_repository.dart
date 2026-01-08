import '../contractor/privacy_policy_contractor.dart';
import '../models/remote/privacy_policy_response.dart';
import '../services/remote/policy_service.dart';

class PrivacyPolicyRepository implements PrivacyPolicyContractor {
  PrivacyPolicyRepository(this._service);

  final PrivacyPolicyService _service;

  @override
  Future<PolicyResponse> getPrivacyPolicy() {
    return _service.getPrivacyPolicy();
  }
}
