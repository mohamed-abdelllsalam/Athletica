import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/usecases/mark_profile_complete_usecase.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:athletica/features/info/domain/usecases/get_client_answers_usecase.dart';
import 'package:athletica/features/info/domain/usecases/get_client_questions_usecase.dart';
import 'package:athletica/features/info/domain/usecases/submit_client_answers_usecase.dart';
import 'package:athletica/features/info/domain/usecases/update_client_answers_usecase.dart';
import 'package:athletica/features/info/presentation/cubits/info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoCubit extends Cubit<InfoState> {
  InfoCubit(
    this._getQuestions,
    this._getClientAnswers,
    this._submitAnswers,
    this._updateAnswers,
    this._markProfileComplete,
  ) : super(const InfoInitial());

  final GetClientQuestionsUseCase _getQuestions;
  final GetClientAnswersUseCase _getClientAnswers;
  final SubmitClientAnswersUseCase _submitAnswers;
  final UpdateClientAnswersUseCase _updateAnswers;
  final MarkProfileCompleteUseCase _markProfileComplete;

  /// Whether the backend already had stored answers for this client.
  /// When true, saving uses PATCH instead of POST to avoid duplicates.
  bool _hasExistingAnswers = false;
  bool _loadingQuestions = false;

  Future<void> loadQuestions() async {
    if (state is InfoQuestionsLoaded) return;
    if (_loadingQuestions || state is InfoQuestionsLoading || isClosed) return;
    _loadingQuestions = true;
    try {
      emit(const InfoQuestionsLoading());

      final result = await _getQuestions();
      switch (result) {
        case ApiSuccess(:final data):
          await _loadSavedAnswers(data);
        case ApiError(:final failure):
          if (isClosed) return;
          emit(
            InfoQuestionsError(
              failure.message,
              isConnectionError: failure is NetworkFailure,
            ),
          );
      }
    } finally {
      _loadingQuestions = false;
    }
  }

  Future<void> _loadSavedAnswers(List<ClientQuestion> questions) async {
    // Failure to load previous answers must not block the questionnaire;
    // the flow simply behaves like a first submission (POST).
    var saved = const ClientAnswers(answers: []);
    if (questions.isNotEmpty) {
      final answersResult = await _getClientAnswers();
      if (answersResult case ApiSuccess(:final data)) {
        saved = data;
      } else if (answersResult case ApiError(
        failure: NetworkFailure(:final message),
      )) {
        if (isClosed) return;
        emit(InfoQuestionsError(message, isConnectionError: true));
        return;
      }
    }

    _hasExistingAnswers = saved.answers.isNotEmpty;
    if (isClosed) return;
    emit(
      InfoQuestionsLoaded(
        questions,
        savedAnswers: restoreAnswers(questions, saved),
      ),
    );
  }

  /// Matches stored answers to questions by `question_id` and converts
  /// them to UI-ready values, following each question's type:
  /// choice -> int index ("0" strings are parsed safely), text -> String.
  /// Invalid or out-of-range choice indexes and empty text are dropped.
  ///
  /// Saved answers may reference either the English or Arabic question ID,
  /// so both are mapped to the merged question's canonical ID.
  static Map<String, Object> restoreAnswers(
    List<ClientQuestion> questions,
    ClientAnswers saved,
  ) {
    final questionByAnyId = <String, ClientQuestion>{
      for (final q in questions) q.id: q,
      for (final q in questions)
        if (q.arabicId != null) q.arabicId!: q,
    };
    final restored = <String, Object>{};

    for (final answer in saved.answers) {
      final question = questionByAnyId[answer.questionId];
      if (question == null) continue;

      if (question.questionType == QuestionType.choice) {
        final index =
            int.tryParse(answer.answer.toString()) ??
            (answer.answer is double
                ? (answer.answer as double).toInt()
                : null);
        if (index == null || index < 0 || index >= question.choices.length) {
          continue;
        }
        restored[question.id] = index;
      } else {
        final text = answer.answer.toString().trim();
        if (text.isEmpty) continue;
        restored[question.id] = text;
      }
    }
    return restored;
  }

  Future<void> submitAnswers(Map<String, Object> answers) async {
    emit(const InfoLoading());

    final result = _hasExistingAnswers
        ? await _updateAnswers(answers)
        : await _submitAnswers(answers);
    if (result case ApiError(:final failure)) {
      if (isClosed) return;
      emit(InfoError(failure.message));
      return;
    }
    _hasExistingAnswers = true;

    try {
      await _markProfileComplete();
      if (isClosed) return;
      emit(const InfoSuccess());
    } catch (_) {
      if (isClosed) return;
      emit(const InfoError('Failed to complete profile. Please try again.'));
    }
  }
}
