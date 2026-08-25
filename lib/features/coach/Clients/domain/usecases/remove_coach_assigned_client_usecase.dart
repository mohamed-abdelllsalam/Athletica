import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';

/// Removes a client from the coach's roster (`DELETE /coach/clients/:id`).
/// [coachClientId] is the `coach_clients.id`. Cascades all nutrition and
/// workout plan data for that client.
class RemoveCoachAssignedClientUseCase {
  const RemoveCoachAssignedClientUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<void>> call(String coachClientId) =>
      _repository.removeAssignedClient(coachClientId);
}
