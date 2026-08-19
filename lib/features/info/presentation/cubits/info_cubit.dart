import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/info/domain/usecases/get_client_questions_usecase.dart';
import 'package:athletica/features/info/domain/usecases/submit_client_answers_usecase.dart';
import 'package:athletica/features/info/presentation/cubits/info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoCubit extends Cubit<InfoState> {
  InfoCubit(this._getQuestions, this._submitAnswers, this._markProfileComplete)
    : super(const InfoInitial());

  final GetClientQuestionsUseCase _getQuestions;
  final SubmitClientAnswersUseCase _submitAnswers;
  final MarkProfileCompleteUseCase _markProfileComplete;

  Future<void> loadQuestions() async {
    if (state is InfoQuestionsLoaded) return;
    emit(const InfoQuestionsLoading());

    final result = await _getQuestions();
    switch (result) {
      case ApiSuccess(:final data):
        emit(InfoQuestionsLoaded(data));
      case ApiError(:final failure):
        emit(InfoQuestionsError(failure.message));
    }
  }

  Future<void> submitAnswers(Map<String, int> answers) async {
    emit(const InfoLoading());

    final result = await _submitAnswers(answers);
    if (result case ApiError(:final failure)) {
      emit(InfoError(failure.message));
      return;
    }

    try {
      await _markProfileComplete();
      emit(const InfoSuccess());
    } catch (_) {
      emit(const InfoError('Failed to complete profile. Please try again.'));
    }
  }
}
