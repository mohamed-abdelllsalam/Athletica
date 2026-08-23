import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class DeleteNutritionPlanUseCase {
  const DeleteNutritionPlanUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<void>> call(String planId) =>
      _repository.deleteNutritionPlan(planId);
}
