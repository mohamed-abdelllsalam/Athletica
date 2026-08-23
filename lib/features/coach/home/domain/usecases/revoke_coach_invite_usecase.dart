import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/home/domain/repositories/coach_invite_repository.dart';

class RevokeCoachInviteUseCase {
  const RevokeCoachInviteUseCase(this._repository);

  final CoachInviteRepository _repository;

  Future<ApiResult<void>> call() => _repository.revokeInviteCode();
}
