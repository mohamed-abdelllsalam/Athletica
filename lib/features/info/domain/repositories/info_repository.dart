import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/intake_answer.dart';
import 'package:athletica/features/info/domain/entities/intake_section.dart';

abstract class InfoRepository {
  Future<ApiResult<List<IntakeSection>>> getQuestions();
  Future<ApiResult<void>> submitAnswers(Map<String, dynamic> answers);
  Future<ApiResult<ClientIntakeAnswers>> getClientAnswers(String clientId);
}
