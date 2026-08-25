import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';

/// Lists clients assigned to the authenticated coach (`GET /coach/clients`).
class GetCoachAssignedClientsUseCase {
  const GetCoachAssignedClientsUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<List<CoachAssignedClient>>> call() =>
      _repository.getAssignedClients();
}
