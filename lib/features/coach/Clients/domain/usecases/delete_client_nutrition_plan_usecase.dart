import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/clients/domain/repositories/coach_clients_repository.dart';

class DeleteClientNutritionPlanUseCase {
  const DeleteClientNutritionPlanUseCase(this._repository);

  final CoachClientsRepository _repository;

  Future<ApiResult<void>> call(String planId) =>
      _repository.deleteNutritionPlan(planId);
}
