import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';

class SubmitIntakeAnswersUseCase {
  const SubmitIntakeAnswersUseCase(this._repository);

  final InfoRepository _repository;

  Future<ApiResult<void>> call(Map<String, String> answers) =>
      _repository.submitAnswers(answers);
}
