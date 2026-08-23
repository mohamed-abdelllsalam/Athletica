import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

/// Removes the coach-client relationship (`DELETE /coach/clients/:id`).
/// [coachClientId] must be the `coach_clients.id` — the same id used to
/// assign a nutrition plan. Cascades all plan data for that client.
class RemoveAssignedClientUseCase {
  const RemoveAssignedClientUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(String coachClientId) =>
      _repository.removeAssignedClient(coachClientId);
}
