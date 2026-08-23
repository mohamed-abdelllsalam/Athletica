import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class AddPlanFoodUseCase {
  const AddPlanFoodUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<void>> call(
    String planId,
    String mealId, {
    required String foodId,
    required num quantity,
  }) =>
      _repository.addPlanFood(
        planId,
        mealId,
        foodId: foodId,
        quantity: quantity,
      );
}
