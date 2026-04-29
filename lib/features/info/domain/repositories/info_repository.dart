import 'package:athletica/core/utils/api_result.dart';

abstract class InfoRepository {
  Future<ApiResult<void>> submitAnswers(Map<String, String> answers);
}