import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class DeletePlanMealUseCase {
  const DeletePlanMealUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<void>> call(String planId, String mealId) =>
      _repository.deletePlanMeal(planId, mealId);
}
