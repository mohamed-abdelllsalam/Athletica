import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/client_coach/domain/entities/coach_link_request.dart';
import 'package:athletica/features/client_coach/domain/repositories/client_coach_repository.dart';

/// Submits a coach invite token (`POST /coach-requests`). May fail with
/// `invalid_or_expired_token`, `cannot_assign_self`, `already_have_coach`
/// or `wait_before_resubmit`.
class SubmitCoachInviteTokenUseCase {
  const SubmitCoachInviteTokenUseCase(this._repository);

  final ClientCoachRepository _repository;

  Future<ApiResult<CoachLinkRequest>> call(String token) =>
      _repository.submitInviteToken(token);
}
