import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class UpdatePlanMealUseCase {
  const UpdatePlanMealUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<void>> call(
    String planId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  }) =>
      _repository.updatePlanMeal(
        planId,
        mealId,
        mealType: mealType,
        mealOrder: mealOrder,
        notes: notes,
      );
}
