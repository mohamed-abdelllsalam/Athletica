import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/info/data/models/client_answers_model.dart';
import 'package:athletica/features/info/data/models/client_question_model.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:dio/dio.dart';

abstract class InfoRemoteDataSource {
  Future<List<ClientQuestion>> getQuestions();
  Future<void> submitAnswers(Map<String, int> answers);
  Future<ClientAnswers> getClientAnswers();
}

class InfoRemoteDataSourceImpl implements InfoRemoteDataSource {
  const InfoRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ClientQuestion>> getQuestions() async {
    final response = await _dio.get(ApiEndpoints.clientQuestions);
    final data = response.data as Map<String, dynamic>;
    final questions = data['questions'] as List<dynamic>? ?? const [];
    return questions
        .map((q) => ClientQuestionModel.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> submitAnswers(Map<String, int> answers) async {
    final payload = answers.entries
        .map((e) => {'question_id': e.key, 'answer': e.value})
        .toList();
    await _dio.post(ApiEndpoints.clientAnswers, data: {'answers': payload});
  }

  @override
  Future<ClientAnswers> getClientAnswers() async {
    final response = await _dio.get(ApiEndpoints.clientAnswers);
    final data = response.data as Map<String, dynamic>;
    return ClientAnswersModel.fromJson(data);
  }
}
