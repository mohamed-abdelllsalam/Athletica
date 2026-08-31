import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:athletica/features/info/domain/usecases/get_client_answers_usecase.dart';
import 'package:athletica/features/info/domain/usecases/get_client_questions_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit(this._getClientAnswers, this._getClientQuestions)
    : super(const ProfileInfoInitial());

  final GetClientAnswersUseCase _getClientAnswers;
  final GetClientQuestionsUseCase _getClientQuestions;
  bool _loaded = false;

  int? _parseChoiceIndex(Object answer) {
    if (answer is int) return answer;
    if (answer is String) return int.tryParse(answer);
    return null;
  }

  Future<void> loadAnswers({bool forceRefresh = false}) async {
    if (!forceRefresh && (_loaded || state is ProfileInfoLoading)) return;
    emit(const ProfileInfoLoading());

    final answersResult = await _getClientAnswers();
    final List<ClientAnswer> answers;
    switch (answersResult) {
      case ApiSuccess(:final data):
        answers = data.answers;
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ProfileInfoError(failure.message));
        return;
    }

    final questionsResult = await _getClientQuestions();
    final List<ClientQuestion> questions;
    switch (questionsResult) {
      case ApiSuccess(:final data):
        questions = data;
      case ApiError(:final failure):
        if (isClosed) return;
        emit(ProfileInfoError(failure.message));
        return;
    }

    final questionMap = <String, ClientQuestion>{};
    for (final q in questions) {
      questionMap[q.id] = q;
      if (q.arabicId != null) questionMap[q.arabicId!] = q;
    }

    final resolved = answers.map((a) {
      final question = questionMap[a.questionId];
      if (question == null) return a;

      final qEn = question.questionEn ?? question.question;
      final qAr = question.questionAr ?? question.question;

      final idx = _parseChoiceIndex(a.answer);
      if (idx == null || idx < 0 || idx >= question.choices.length) {
        return ClientAnswer(
          questionId: a.questionId,
          answer: a.answer,
          question: '$qEn / $qAr',
        );
      }

      final choiceEn = question.choicesEn ?? question.choices;
      final choiceAr = question.choicesAr ?? question.choices;
      final enText = idx < choiceEn.length
          ? choiceEn[idx]
          : question.choices[idx];
      final arText = idx < choiceAr.length ? choiceAr[idx] : enText;

      return ClientAnswer(
        questionId: a.questionId,
        answer: '$enText / $arText',
        question: '$qEn / $qAr',
      );
    }).toList();

    _loaded = true;
    if (isClosed) return;
    emit(ProfileInfoLoaded(resolved));
  }
}
