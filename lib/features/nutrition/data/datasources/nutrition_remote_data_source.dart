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
    final defaultFuture = _dio.get(ApiEndpoints.nutritionToday);
    final arFuture = _dio.get(
      ApiEndpoints.nutritionToday,
      queryParameters: {'lang': 'ar'},
    );
    final enFuture = _dio.get(
      ApiEndpoints.nutritionToday,
      queryParameters: {'lang': 'en'},
    );

    final results = await Future.wait([defaultFuture, arFuture, enFuture]);
    final defaultData = results[0].data as Map<String, dynamic>? ?? {};
    final arData = results[1].data as Map<String, dynamic>? ?? {};
    final enData = results[2].data as Map<String, dynamic>? ?? {};

    _mergeFoodNames(defaultData, arData, enData);
    return TodayMealsModel.fromJson(defaultData);
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
    final defaultFuture = _dio.get(ApiEndpoints.nutritionMyPlan(planId));
    final arFuture = _dio.get(
      ApiEndpoints.nutritionMyPlan(planId),
      queryParameters: {'lang': 'ar'},
    );
    final enFuture = _dio.get(
      ApiEndpoints.nutritionMyPlan(planId),
      queryParameters: {'lang': 'en'},
    );

    final results = await Future.wait([defaultFuture, arFuture, enFuture]);
    final defaultData = results[0].data as Map<String, dynamic>? ?? {};
    final arData = results[1].data as Map<String, dynamic>? ?? {};
    final enData = results[2].data as Map<String, dynamic>? ?? {};

    _mergeFoodNames(defaultData, arData, enData);
    final model = MyPlanModel.fromResponse(defaultData);
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

  /// Merges localized food names from [arData] and [enData] into [defaultData]
  /// by matching `food_id` across all three responses.
  void _mergeFoodNames(
    Map<String, dynamic> defaultData,
    Map<String, dynamic> arData,
    Map<String, dynamic> enData,
  ) {
    final arMap = _buildFoodNameMap(arData, langKey: 'name_ar');
    final enMap = _buildFoodNameMap(enData, langKey: 'name_en');
    _injectNames(defaultData, arMap, enMap);
  }

  /// Extracts a `{ food_id → food_name }` map from a response.
  /// Reads both `food_name` and `name_ar`/`name_en` to handle different
  /// API naming conventions across `?lang=` variants.
  Map<String, String> _buildFoodNameMap(
    Map<String, dynamic> data, {
    String? langKey,
  }) {
    final meals = _extractMeals(data);
    final map = <String, String>{};
    for (final meal in meals) {
      if (meal is! Map<String, dynamic>) continue;
      final foods = meal['foods'] as List<dynamic>? ?? [];
      for (final food in foods) {
        if (food is! Map<String, dynamic>) continue;
        final id = food['food_id'] as String? ?? food['id'] as String? ?? '';
        if (id.isEmpty) continue;
        final name = (food['food_name'] as String? ?? '').trim();
        final localizedName = langKey != null
            ? (food[langKey] as String? ?? '').trim()
            : '';
        final best = localizedName.isNotEmpty ? localizedName : name;
        if (best.isNotEmpty) map[id] = best;
      }
    }
    return map;
  }

  void _injectNames(
    Map<String, dynamic> data,
    Map<String, String> arMap,
    Map<String, String> enMap,
  ) {
    final meals = _extractMeals(data);
    for (final meal in meals) {
      if (meal is! Map<String, dynamic>) continue;
      final foods = meal['foods'] as List<dynamic>? ?? [];
      for (final food in foods) {
        if (food is! Map<String, dynamic>) continue;
        final id = food['food_id'] as String? ?? food['id'] as String? ?? '';
        if (id.isEmpty) continue;
        final ar = arMap[id];
        final en = enMap[id];
        if (ar != null) food['food_name_ar'] = ar;
        if (en != null) food['food_name_en'] = en;
      }
    }
  }

  /// Returns the meals list from either `/today` (flat) or `/my/plans/:id`
  /// (nested inside `plan`).
  List<dynamic> _extractMeals(Map<String, dynamic> data) {
    final plan = data['plan'];
    if (plan is Map<String, dynamic>) {
      return plan['meals'] as List<dynamic>? ?? [];
    }
    return data['meals'] as List<dynamic>? ?? [];
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
