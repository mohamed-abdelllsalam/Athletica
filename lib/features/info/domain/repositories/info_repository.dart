import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';

abstract class InfoRepository {
  Future<ApiResult<List<ClientQuestion>>> getQuestions();
  Future<ApiResult<void>> submitAnswers(Map<String, int> answers);
  Future<ApiResult<ClientAnswers>> getClientAnswers();
}
