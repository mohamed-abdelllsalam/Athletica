import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

class GetClientSubmissionDetailUseCase {
  const GetClientSubmissionDetailUseCase(this._repository);
  final CheckInsRepository _repository;
  Future<ApiResult<CheckInSubmission>> call(String submissionId) =>
      _repository.getClientSubmissionDetail(submissionId);
}
