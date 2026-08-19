import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/client_answers.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';

class GetClientAnswersUseCase {
  const GetClientAnswersUseCase(this._repository);

  final InfoRepository _repository;

  Future<ApiResult<ClientAnswers>> call() => _repository.getClientAnswers();
}
