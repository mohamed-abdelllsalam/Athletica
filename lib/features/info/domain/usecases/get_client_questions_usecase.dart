import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';

class GetClientQuestionsUseCase {
  const GetClientQuestionsUseCase(this._repository);

  final InfoRepository _repository;

  Future<ApiResult<List<ClientQuestion>>> call() => _repository.getQuestions();
}
