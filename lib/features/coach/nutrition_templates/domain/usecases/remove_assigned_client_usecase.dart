import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

/// Removes the coach-client relationship (`DELETE /coach/clients/:id`).
/// [clientId] is the `client_profiles.id` (DOC_2 §6.7) — not the
/// `coach_clients.id` relation id used for assignment. Cascades all plan
/// data for that client.
class RemoveAssignedClientUseCase {
  const RemoveAssignedClientUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(String clientId) =>
      _repository.removeAssignedClient(clientId);
}
