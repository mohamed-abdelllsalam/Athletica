import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

class GetCheckInQuestionsUseCase {
  const GetCheckInQuestionsUseCase(this._repository);
  final CheckInsRepository _repository;

  /// Coach form (`C1`) by default; client pending form (`L2`, `[]` when no
  /// pending) when [coachView] is false.
  Future<ApiResult<List<CheckInQuestion>>> call({bool coachView = true}) =>
      _repository.getQuestions(coachView: coachView);
}
