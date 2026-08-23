import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_nutrition_plan.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class GetNutritionPlanUseCase {
  const GetNutritionPlanUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<CoachNutritionPlan>> call(String planId) =>
      _repository.getNutritionPlan(planId);
}
