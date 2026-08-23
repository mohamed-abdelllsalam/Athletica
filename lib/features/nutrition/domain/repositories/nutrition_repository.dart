import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';

abstract class NutritionRepository {
  Future<ApiResult<TodayMeals>> getTodayMeals();
  Future<ApiResult<TodayMeals>> completeMeal(String mealLogId);
  Future<ApiResult<TodayMeals>> uncompleteMeal(String mealLogId);
}
