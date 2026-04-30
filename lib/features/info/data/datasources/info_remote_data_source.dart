import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/info/data/models/client_intake_answers_model.dart';
import 'package:athletica/features/info/data/models/intake_section_model.dart';
import 'package:athletica/features/info/domain/entities/intake_answer.dart';
import 'package:athletica/features/info/domain/entities/intake_section.dart';
import 'package:dio/dio.dart';

abstract class InfoRemoteDataSource {
  Future<List<IntakeSection>> getQuestions();
  Future<void> submitAnswers(Map<String, dynamic> answers);
  Future<ClientIntakeAnswers> getClientAnswers(String clientId);
}

class InfoRemoteDataSourceImpl implements InfoRemoteDataSource {
  const InfoRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<IntakeSection>> getQuestions() async {
    final response = await _dio.get(ApiEndpoints.clientIntakeQuestions);
    final data = response.data['data'] as Map<String, dynamic>;
    final pages = data['pages'] as List<dynamic>;
    return pages
        .map((s) => IntakeSectionModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> submitAnswers(Map<String, dynamic> answers) async {
    await _dio.post(
      ApiEndpoints.clientIntakeAnswers,
      data: {'answers': answers},
    );
  }

  @override
  Future<ClientIntakeAnswers> getClientAnswers(String clientId) async {
    final response = await _dio.get(
      ApiEndpoints.clientIntakeAnswersByClient(clientId),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ClientIntakeAnswersModel.fromJson(data);
  }
}
