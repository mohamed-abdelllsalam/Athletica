import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';

class GetCoachClientsUseCase {
  const GetCoachClientsUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<List<CoachClient>>> call(String trainerId) =>
      _repository.getClientsByTrainerId(trainerId);
}
