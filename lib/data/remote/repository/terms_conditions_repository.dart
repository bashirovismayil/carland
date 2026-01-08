import '../contractor/terms_and_conditions_contractor.dart';
import '../models/remote/terms_conditions_response.dart';
import '../services/remote/terms_conditions_service.dart';

class TermsConditionsRepository implements TermsConditionsContractor {
  TermsConditionsRepository(this._service);

  final TermsConditionsService _service;

  @override
  Future<TermsConditionsResponse> getTermsConditions() {
    return _service.getTermsConditions();
  }
}