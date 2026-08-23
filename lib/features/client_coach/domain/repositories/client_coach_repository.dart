import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';
import 'package:athletica/features/client_coach/domain/entities/coach_link_request.dart';

abstract class ClientCoachRepository {
  /// Submits an invite token to request the coach.
  Future<ApiResult<CoachLinkRequest>> submitInviteToken(String token);

  /// Returns null when no coach is assigned yet.
  Future<ApiResult<AssignedCoach?>> getMyCoach();

  /// Leaves the current coach. Cascades all plan data.
  Future<ApiResult<void>> leaveCoach();
}
