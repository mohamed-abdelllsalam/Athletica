import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Coach submission detail (`C8`). Answers keep backend order and may carry
/// a null `question_id` (deleted question) — render from the snapshot.
class GetCoachSubmissionDetailUseCase {
  const GetCoachSubmissionDetailUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<CheckInSubmission>> call({
    required String coachClientId,
    required String submissionId,
  }) =>
      _repository.getCoachSubmissionDetail(coachClientId, submissionId);
}
