import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';

class GetClientDetailUseCase {
  const GetClientDetailUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<ClientDetail>> call(String clientId) =>
      _repository.getClientDetail(clientId);
}
