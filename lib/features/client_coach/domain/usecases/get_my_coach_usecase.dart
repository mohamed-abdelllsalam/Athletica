import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';
import 'package:athletica/features/client_coach/domain/repositories/client_coach_repository.dart';

/// Returns null when the client has no assigned coach yet.
class GetMyCoachUseCase {
  const GetMyCoachUseCase(this._repository);

  final ClientCoachRepository _repository;

  Future<ApiResult<AssignedCoach?>> call() => _repository.getMyCoach();
}
