import '../../data/remote/models/remote/privacy_policy_response.dart';

sealed class PrivacyPolicyState {}

final class PrivacyPolicyInitial extends PrivacyPolicyState {}

final class PrivacyPolicyLoading extends PrivacyPolicyState {}

final class PrivacyPolicySuccess extends PrivacyPolicyState {
  final PolicyResponse policyData;
  PrivacyPolicySuccess(this.policyData);
}

final class PrivacyPolicyError extends PrivacyPolicyState {
  final String message;
  PrivacyPolicyError(this.message);
}