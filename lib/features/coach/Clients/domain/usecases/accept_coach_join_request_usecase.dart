import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_join_requests_repository.dart';

class AcceptCoachJoinRequestUseCase {
  const AcceptCoachJoinRequestUseCase(this._repository);

  final CoachJoinRequestsRepository _repository;

  Future<ApiResult<void>> call(String requestId) =>
      _repository.acceptJoinRequest(requestId);
}
