import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';

abstract class CoachJoinRequestsRepository {
  /// Returns all incoming requests (any status) for the signed-in coach.
  Future<ApiResult<List<JoinRequest>>> getJoinRequests();

  Future<ApiResult<void>> acceptJoinRequest(String requestId);

  Future<ApiResult<void>> rejectJoinRequest(String requestId);
}
