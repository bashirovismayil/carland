import '../models/remote/privacy_policy_response.dart';

abstract class PrivacyPolicyContractor {
  Future<PolicyResponse> getPrivacyPolicy();
}