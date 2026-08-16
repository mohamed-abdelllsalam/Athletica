import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_home_stats.dart';

class GetCoachHomeStatsUseCase {
  const GetCoachHomeStatsUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<CoachHomeStats>> call(String trainerId) async {
    final result = await _repository.getClientsByTrainerId(trainerId);
    switch (result) {
      case ApiSuccess(:final data):
        final stats = CoachHomeStats(
          totalClients: data.length,
          activeClients: data.where((c) => c.subscriptionActive).length,
          expiringSubscriptions: _countExpiring(data),
        );
        return ApiSuccess(stats);
      case ApiError(:final failure):
        return ApiError(failure);
    }
  }

  int _countExpiring(List<CoachClient> clients) {
    var count = 0;
    for (final client in clients) {
      if (!client.subscriptionActive) continue;
      final expiresInDays = _resolveExpiresInDays(client);
      if (expiresInDays == null) continue;
      if (expiresInDays >= 0) {
        count++;
      }
    }
    return count;
  }

  int? _resolveExpiresInDays(CoachClient client) {
    if (client.expiresInDays != null) return client.expiresInDays;
    final endDate = _parseDate(client.subscriptionEndDate);
    if (endDate == null) return null;
    return endDate.difference(DateTime.now()).inDays;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
