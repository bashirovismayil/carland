import '../../data/remote/models/remote/terms_conditions_response.dart';

sealed class TermsConditionsState {}

final class TermsConditionsInitial extends TermsConditionsState {}

final class TermsConditionsLoading extends TermsConditionsState {}

final class TermsConditionsSuccess extends TermsConditionsState {
  final TermsConditionsResponse termsData;
  TermsConditionsSuccess(this.termsData);
}

final class TermsConditionsError extends TermsConditionsState {
  final String message;
  TermsConditionsError(this.message);
}