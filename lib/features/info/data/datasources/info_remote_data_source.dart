import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/info/data/models/client_answers_model.dart';
import 'package:athletica/features/info/data/models/client_question_model.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:dio/dio.dart';

abstract class InfoRemoteDataSource {
  Future<List<ClientQuestion>> getQuestions();
  Future<void> submitAnswers(ClientAnswerPayload answers);
  Future<void> updateAnswers(ClientAnswerPayload answers);
  Future<ClientAnswers> getClientAnswers();
}

class InfoRemoteDataSourceImpl implements InfoRemoteDataSource {
  const InfoRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const Map<String, String> _headers = {'Accept-Language': 'en'};

  static const Map<String, String> _arHeaders = {'Accept-Language': 'ar'};

  /// Fetches the questions in both supported languages and merges them so
  /// every label carries both translations ("عربي / English").
  ///
  /// All content comes from the backend — no labels are localized here.
  @override
  Future<List<ClientQuestion>> getQuestions() async {
    final results = await Future.wait([
      _fetchQuestions(_arHeaders),
      _fetchQuestions(_headers),
    ]);
    return mergeQuestions(arabic: results[0], english: results[1]);
  }

  Future<List<ClientQuestionModel>> _fetchQuestions(
    Map<String, String> headers,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.clientQuestions,
      options: Options(headers: headers),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) return const [];
    final questions = data['questions'] as List<dynamic>? ?? const [];
    return questions
        .whereType<Map<String, dynamic>>()
        .map(ClientQuestionModel.fromJson)
        .toList();
  }

  /// Merges Arabic and English question sets by [ClientQuestion.groupKey].
  ///
  /// English records define canonical ordering and provide the primary [id]
  /// used for answer submission. Arabic records are matched by [groupKey]
  /// and their [id] is stored as [ClientQuestion.arabicId] so saved answers
  /// referencing either language can be restored.
  ///
  /// Questions present in only one language pass through untouched.
  /// If a question's choice counts differ between languages the English
  /// version is preferred; the Arabic version is kept whole as fallback.
  static List<ClientQuestion> mergeQuestions({
    required List<ClientQuestionModel> arabic,
    required List<ClientQuestionModel> english,
  }) {
    if (english.isEmpty) return arabic;

    final arabicByGroupKey = {for (final q in arabic) q.groupKey: q};
    final merged = <ClientQuestion>[];

    for (final en in english) {
      final ar = arabicByGroupKey.remove(en.groupKey);
      if (ar == null || en.choices.length != ar.choices.length) {
        merged.add(en);
        continue;
      }
      merged.add(
        ClientQuestionModel(
          id: en.id,
          groupKey: en.groupKey,
          questionType: en.questionType,
          language: en.language,
          createdAt: en.createdAt,
          questionEn: en.question,
          questionAr: ar.question,
          choicesEn: en.choices,
          choicesAr: ar.choices,
          arabicId: ar.id,
          question: en.question,
          choices: en.choices,
        ),
      );
    }

    for (final ar in arabicByGroupKey.values) {
      merged.add(ar);
    }

    return merged;
  }

  @override
  Future<void> submitAnswers(ClientAnswerPayload answers) =>
      _sendAnswers(_dio.post, ApiEndpoints.clientAnswers, answers);

  @override
  Future<void> updateAnswers(ClientAnswerPayload answers) =>
      _sendAnswers(_dio.patch, ApiEndpoints.clientAnswers, answers);

  Future<void> _sendAnswers(
    Future<Response<dynamic>> Function(String path, {Object? data}) request,
    String path,
    ClientAnswerPayload answers,
  ) async {
    final payload = answers.entries
        .map((e) => {'question_id': e.key, 'answer': e.value})
        .toList();
    await request(path, data: {'answers': payload});
  }

  @override
  Future<ClientAnswers> getClientAnswers() async {
    final response = await _dio.get(
      ApiEndpoints.clientAnswers,
      options: Options(headers: _headers),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return const ClientAnswersModel(answers: []);
    }
    return ClientAnswersModel.fromJson(data);
  }
}
