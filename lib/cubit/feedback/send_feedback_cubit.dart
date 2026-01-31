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
      return types.where((type) => type == 'support' || type == 'bug_report').toList();
    } catch (e) {
      emit(FeedbackError(e.toString()));
      return [];
    }
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
      print(">>> API cevap geldi: $response");
      emit(FeedbackSuccess(response));
    } catch (e) {
      print(">>> HATA: $e");
      emit(FeedbackError(e.toString()));
    }
  }
}