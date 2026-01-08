import '../models/remote/terms_conditions_response.dart';

abstract class TermsConditionsContractor {
  Future<TermsConditionsResponse> getTermsConditions();
}