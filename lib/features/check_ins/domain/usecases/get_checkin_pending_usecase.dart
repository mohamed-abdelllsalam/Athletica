import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Client pending flag (`L1`). The questions list is only visible while a
/// pending assignment exists.
class GetCheckinPendingUseCase {
  const GetCheckinPendingUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<bool>> call() => _repository.hasPendingAssignment();
}
