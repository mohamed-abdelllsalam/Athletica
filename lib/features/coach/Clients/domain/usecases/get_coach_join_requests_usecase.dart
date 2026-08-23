import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_join_requests_repository.dart';

/// Returns only the pending join requests — accepted/rejected history is not
/// actionable in the requests screen.
class GetCoachJoinRequestsUseCase {
  const GetCoachJoinRequestsUseCase(this._repository);

  final CoachJoinRequestsRepository _repository;

  Future<ApiResult<List<JoinRequest>>> call() async {
    final result = await _repository.getJoinRequests();
    return switch (result) {
      ApiSuccess(:final data) => ApiSuccess(
          data.where((r) => r.status == 'pending').toList(),
        ),
      ApiError(:final failure) => ApiError(failure),
    };
  }
}
