import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/intake_answer.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';

class GetClientIntakeAnswersUseCase {
  const GetClientIntakeAnswersUseCase(this._repository);

  final InfoRepository _repository;

  Future<ApiResult<ClientIntakeAnswers>> call(String clientId) =>
      _repository.getClientAnswers(clientId);
}
