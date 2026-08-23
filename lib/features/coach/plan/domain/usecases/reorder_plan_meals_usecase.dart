import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class ReorderPlanMealsUseCase {
  const ReorderPlanMealsUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<void>> call(
    String planId,
    List<({String mealId, int mealOrder})> mealOrders,
  ) =>
      _repository.reorderPlanMeals(planId, mealOrders);
}
