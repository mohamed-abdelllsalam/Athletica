import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';

/// Updates already-submitted answers (PATCH /client/answers) so that
/// editing existing answers never creates duplicates.
class UpdateClientAnswersUseCase {
  const UpdateClientAnswersUseCase(this._repository);

  final InfoRepository _repository;

  Future<ApiResult<void>> call(ClientAnswerPayload answers) =>
      _repository.updateAnswers(answers);
}
