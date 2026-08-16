import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/info/domain/entities/intake_section.dart';
import 'package:athletica/features/info/domain/repositories/info_repository.dart';

class GetIntakeQuestionsUseCase {
  const GetIntakeQuestionsUseCase(this._repository);

  final InfoRepository _repository;

  Future<ApiResult<List<IntakeSection>>> call() => _repository.getQuestions();
}
