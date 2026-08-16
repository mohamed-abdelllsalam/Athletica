import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_home_stats.dart';
import 'package:athletica/features/coach/home/domain/usecases/get_coach_home_stats_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCoachClientsRepository implements CoachClientsRepository {
  _FakeCoachClientsRepository(this.result);

  ApiResult<List<CoachClient>> result;

  @override
  Future<ApiResult<List<CoachClient>>> getClientsByTrainerId(
    String trainerId,
  ) async {
    return result;
  }
}

void main() {
  test('returns counts from clients list', () async {
    final clients = [
      const CoachClient(
        id: '1',
        name: 'Client A',
        joinedMonthsAgo: 1,
        subscriptionActive: true,
        expiresInDays: 5,
      ),
      const CoachClient(
        id: '2',
        name: 'Client B',
        joinedMonthsAgo: 2,
        subscriptionActive: false,
        expiresInDays: 3,
      ),
      const CoachClient(
        id: '3',
        name: 'Client C',
        joinedMonthsAgo: 3,
        subscriptionActive: true,
      ),
    ];

    final repository = _FakeCoachClientsRepository(ApiSuccess(clients));
    final useCase = GetCoachHomeStatsUseCase(repository);

    final result = await useCase('trainer-1');

    expect(result, isA<ApiSuccess<CoachHomeStats>>());
    final stats = (result as ApiSuccess<CoachHomeStats>).data;
    expect(stats.totalClients, 3);
    expect(stats.activeClients, 2);
    expect(stats.expiringSubscriptions, 1);
  });

  test('returns failure when repository fails', () async {
    const failure = ServerFailure('Server error');
    final repository = _FakeCoachClientsRepository(ApiError(failure));
    final useCase = GetCoachHomeStatsUseCase(repository);

    final result = await useCase('trainer-1');

    expect(result, isA<ApiError<CoachHomeStats>>());
    expect((result as ApiError<CoachHomeStats>).failure, failure);
  });
}
