import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
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

  /// Merges the Arabic and English question sets by [ClientQuestion.id].
  ///
  /// The Arabic response defines order and is the fallback whenever a label
  /// has no translation. Questions present in only one language pass through
  /// untouched. If a question's choice counts differ between languages the
  /// Arabic version is kept whole (safe against backend inconsistencies).
  static List<ClientQuestion> mergeQuestions({
    required List<ClientQuestionModel> arabic,
    required List<ClientQuestionModel> english,
  }) {
    if (english.isEmpty) return arabic;

    final englishById = {for (final q in english) q.id: q};
    final merged = <ClientQuestion>[];
    for (final ar in arabic) {
      final en = englishById[ar.id];
      if (en == null || en.choices.length != ar.choices.length) {
        merged.add(ar);
        continue;
      }
      merged.add(
        ClientQuestionModel(
          id: ar.id,
          groupKey: ar.groupKey,
          questionType: ar.questionType,
          language: ar.language ?? en.language,
          createdAt: ar.createdAt,
          question: buildBilingualLabel(
            primary: ar.question,
            arabic: ar.question,
            english: en.question,
          ),
          choices: [
            for (var i = 0; i < ar.choices.length; i++)
              buildBilingualLabel(
                primary: ar.choices[i],
                arabic: ar.choices[i],
                english: en.choices[i],
              ),
          ],
        ),
      );
    }
    // Questions only returned for English (never expected, but don't drop).
    final mergedIds = merged.map((q) => q.id).toSet();
    for (final en in english) {
      if (!mergedIds.contains(en.id)) merged.add(en);
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
