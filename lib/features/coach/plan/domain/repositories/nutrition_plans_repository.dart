import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_nutrition_plan.dart';

typedef NutritionPlansPageResult = ApiResult<
    ({List<CoachNutritionPlan> plans, ApiPagination pagination})>;

abstract class NutritionPlansRepository {
  Future<NutritionPlansPageResult> getNutritionPlans({
    int page = 1,
    int pageSize = 20,
    String? clientId,
    bool? isActive,
  });

  Future<ApiResult<CoachNutritionPlan>> getNutritionPlan(String planId);

  Future<ApiResult<void>> deleteNutritionPlan(String planId);

  Future<ApiResult<NutritionTemplateMeal>> addPlanMeal(
    String planId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  });

  Future<ApiResult<void>> updatePlanMeal(
    String planId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  });

  Future<ApiResult<void>> deletePlanMeal(String planId, String mealId);

  Future<ApiResult<void>> reorderPlanMeals(
    String planId,
    List<({String mealId, int mealOrder})> mealOrders,
  );

  Future<ApiResult<void>> addPlanFood(
    String planId,
    String mealId, {
    required String foodId,
    required num quantity,
  });

  Future<ApiResult<void>> updatePlanFood(
    String planId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  });

  Future<ApiResult<void>> removePlanFood(
    String planId,
    String mealId,
    String relationFoodId,
  );
}
