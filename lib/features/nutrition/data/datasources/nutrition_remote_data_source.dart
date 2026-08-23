import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/nutrition/data/models/today_meals_model.dart';
import 'package:dio/dio.dart';

abstract class NutritionRemoteDataSource {
  Future<TodayMealsModel> getTodayMeals();
  Future<TodayMealsModel> completeMeal(String mealLogId);
  Future<TodayMealsModel> uncompleteMeal(String mealLogId);
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  const NutritionRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<TodayMealsModel> getTodayMeals() async {
    final response = await _dio.get(ApiEndpoints.nutritionToday);
    final data = response.data as Map<String, dynamic>? ?? {};
    return TodayMealsModel.fromJson(data);
  }

  @override
  Future<TodayMealsModel> completeMeal(String mealLogId) async {
    await _dio.post(ApiEndpoints.nutritionMealComplete(mealLogId));
    return getTodayMeals();
  }

  @override
  Future<TodayMealsModel> uncompleteMeal(String mealLogId) async {
    await _dio.post(ApiEndpoints.nutritionMealUncomplete(mealLogId));
    return getTodayMeals();
  }
}
