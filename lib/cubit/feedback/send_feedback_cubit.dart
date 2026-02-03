import 'package:carcat/cubit/feedback/send_feedback_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/di/locator.dart';
import '../../data/remote/contractor/send_feedback_contractor.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit() : super(FeedbackInitial()) {
    _repo = locator<FeedbackContractor>();
  }
  late final FeedbackContractor _repo;
  Future<void> loadFeedbackTypes() async {
    try {
      emit(FeedbackLoading());
      final types = await _repo.getFeedbackTypes();
      emit(FeedbackTypesLoaded(types));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
  Future<List<String>> getSupportTypes() async {
    try {
      final types = await _repo.getFeedbackTypes();
      return types
          .where((type) => type == 'support' || type == 'bug_report')
          .toList();
    } catch (e) {
      emit(FeedbackError(e.toString()));
      return [];
    }
  }

  FeedbackValidationError? validateSupportForm({
    required String? selectedType,
    required String description,
  }) {
    if (selectedType == null || selectedType.isEmpty) {
      return FeedbackValidationError.typeRequired;
    }

    if (description.trim().isEmpty) {
      return FeedbackValidationError.descriptionRequired;
    }

    return null;
  }

  Future<void> submitFeedback({
    required String type,
    required String subject,
    required String description,
    int? rating,
    String? filePath,
  }) async {
    try {
      emit(FeedbackLoading());
      print(">>> API çağrısı başladı");
      final response = await _repo.sendFeedback(
        type: type,
        subject: subject,
        description: description,
        rating: rating,
        filePath: filePath,
      );
      print(">>> API cavab gəldi: $response");
      emit(FeedbackSuccess(response.message));
    } catch (e) {
      print(">>> XƏTA: $e");
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> submitSupportRequest({
    required String? selectedType,
    required String description,
    String? filePath,
  }) async {
    final validationError = validateSupportForm(
      selectedType: selectedType,
      description: description,
    );

    if (validationError != null) {
      emit(FeedbackValidationFailed(validationError));
      return;
    }

    await submitFeedback(
      type: selectedType!,
      subject: 'Support Topic',
      description: description.trim(),
      filePath: filePath,
    );
  }

  void clearValidationError() {
    if (state is FeedbackValidationFailed) {
      emit(FeedbackInitial());
    }
  }
}

enum FeedbackValidationError {
  typeRequired,
  descriptionRequired,
}