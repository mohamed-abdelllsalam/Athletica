import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/info/domain/usecases/submit_intake_answers_usecase.dart';
import 'package:athletica/features/info/presentation/cubits/info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoCubit extends Cubit<InfoState> {
  InfoCubit(this._submitAnswers, this._markProfileComplete)
      : super(const InfoInitial());

  final SubmitIntakeAnswersUseCase _submitAnswers;
  final MarkProfileCompleteUseCase _markProfileComplete;

  Future<void> submitAnswers(Map<String, String> answers) async {
    emit(const InfoLoading());

    final result = await _submitAnswers(answers);
    if (result is ApiError<void>) {
      emit(InfoError(result.failure.message));
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