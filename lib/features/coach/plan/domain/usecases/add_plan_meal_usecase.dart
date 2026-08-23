import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class AddPlanMealUseCase {
  const AddPlanMealUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<ApiResult<NutritionTemplateMeal>> call(
    String planId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  }) =>
      _repository.addPlanMeal(
        planId,
        mealType: mealType,
        mealOrder: mealOrder,
        notes: notes,
      );
}
