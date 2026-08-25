import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/nutrition/data/models/my_plan_model.dart';
import 'package:athletica/features/nutrition/data/models/nutrition_history_model.dart';
import 'package:athletica/features/nutrition/data/models/today_meals_model.dart';
import 'package:dio/dio.dart';

abstract class NutritionRemoteDataSource {
  Future<TodayMealsModel> getTodayMeals();
  Future<TodayMealsModel> completeMeal(String mealLogId);
  Future<TodayMealsModel> uncompleteMeal(String mealLogId);

  /// Returns null when the client has no active plan (the API answers with
  /// the `no_active_plan_found` error key, or `plan: null`); other errors
  /// are thrown.
  Future<MyPlanModel?> getMyActivePlan();

  Future<MyPlanModel> getMyPlanDetails(String planId);

  /// [from]/[to] are formatted as `YYYY-MM-DD`; the API defaults to the
  /// last 30 days when omitted.
  Future<NutritionHistoryModel> getHistory({DateTime? from, DateTime? to});
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

  @override
  Future<MyPlanModel?> getMyActivePlan() async {
    try {
      final response = await _dio.get(ApiEndpoints.nutritionMyPlans);
      final data = response.data as Map<String, dynamic>? ?? {};
      return MyPlanModel.fromResponse(data);
    } on DioException catch (e) {
      final body = e.response?.data;
      final errorKey = body is Map<String, dynamic> ? body['error'] : null;
      if (_normalizeErrorKey(errorKey) == 'no_active_plan_found') {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<MyPlanModel> getMyPlanDetails(String planId) async {
    final response = await _dio.get(ApiEndpoints.nutritionMyPlan(planId));
    final data = response.data as Map<String, dynamic>? ?? {};
    final model = MyPlanModel.fromResponse(data);
    if (model == null) {
      throw StateError('plan_details_missing');
    }
    return model;
  }

  @override
  Future<NutritionHistoryModel> getHistory({DateTime? from, DateTime? to}) async {
    final response = await _dio.get(
      ApiEndpoints.nutritionHistory,
      queryParameters: {
        if (from != null) 'from': _formatDate(from),
        if (to != null) 'to': _formatDate(to),
      },
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    return NutritionHistoryModel.fromJson(data);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

/// The API documents snake_case error keys but responses carry
/// human-readable values (e.g. "No active plan found"); normalize both so
/// the empty-state detection matches either shape.
String? _normalizeErrorKey(Object? key) =>
    key is String ? key.toLowerCase().trim().replaceAll(' ', '_') : null;
