import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Coach submission history per client (`C7`), newest first.
class GetCoachSubmissionsUseCase {
  const GetCoachSubmissionsUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<List<CheckInSubmission>>> call(String coachClientId) =>
      _repository.getCoachSubmissions(coachClientId);
}
