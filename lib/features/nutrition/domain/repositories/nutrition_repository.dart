import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
import 'package:athletica/features/nutrition/domain/entities/nutrition_history.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';

abstract class NutritionRepository {
  Future<ApiResult<TodayMeals>> getTodayMeals();
  Future<ApiResult<TodayMeals>> completeMeal(String mealLogId);
  Future<ApiResult<TodayMeals>> uncompleteMeal(String mealLogId);

  /// Returns null when the client has no active plan.
  Future<ApiResult<MyPlan?>> getMyActivePlan();

  Future<ApiResult<MyPlan>> getMyPlanDetails(String planId);

  /// [from]/[to] default to the API's last-30-days range when null.
  Future<ApiResult<List<NutritionHistoryDay>>> getHistory({
    DateTime? from,
    DateTime? to,
  });
}
