import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';

/// Removes a client from the coach's roster (`DELETE /coach/clients/:id`).
/// [clientId] is the `client_profiles.id` (DOC_2 §6.7), not the
/// `coach_clients.id` relation id. Cascades all nutrition and
/// workout plan data for that client.
class RemoveCoachAssignedClientUseCase {
  const RemoveCoachAssignedClientUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<void>> call(String clientId) =>
      _repository.removeAssignedClient(clientId);
}
