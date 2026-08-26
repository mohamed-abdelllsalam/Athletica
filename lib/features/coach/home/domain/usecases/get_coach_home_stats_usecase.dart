import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_home_stats.dart';

class GetCoachHomeStatsUseCase {
  const GetCoachHomeStatsUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<CoachHomeStats>> call() async {
    final result = await _repository.getAssignedClients();
    switch (result) {
      case ApiSuccess(:final data):
        final stats = CoachHomeStats(
          totalClients: data.length,
          activeClients: data.length,
          expiringSubscriptions: 0,
        );
        return ApiSuccess(stats);
      case ApiError(:final failure):
        return ApiError(failure);
    }
  }
}
