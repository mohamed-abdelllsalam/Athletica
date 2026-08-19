import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';

class SubmitClientAnswersUseCase {
  const SubmitClientAnswersUseCase(this._repository);

  final InfoRepository _repository;

  Future<ApiResult<void>> call(Map<String, int> answers) =>
      _repository.submitAnswers(answers);
}
