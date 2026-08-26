import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';

abstract class InfoRepository {
  Future<ApiResult<List<ClientQuestion>>> getQuestions();

  /// Creates answers for the first time (POST /client/answers).
  Future<ApiResult<void>> submitAnswers(ClientAnswerPayload answers);

  /// Updates previously submitted answers (PATCH /client/answers).
  Future<ApiResult<void>> updateAnswers(ClientAnswerPayload answers);

  Future<ApiResult<ClientAnswers>> getClientAnswers();
}
