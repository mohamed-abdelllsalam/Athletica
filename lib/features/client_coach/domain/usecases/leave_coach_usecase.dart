import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/client_coach/domain/repositories/client_coach_repository.dart';

class LeaveCoachUseCase {
  const LeaveCoachUseCase(this._repository);

  final ClientCoachRepository _repository;

  Future<ApiResult<void>> call() => _repository.leaveCoach();
}
