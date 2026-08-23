import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class UpdatePlanFoodUseCase {
  const UpdatePlanFoodUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<void>> call(
    String planId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  }) =>
      _repository.updatePlanFood(
        planId,
        mealId,
        relationFoodId,
        quantity: quantity,
      );
}
