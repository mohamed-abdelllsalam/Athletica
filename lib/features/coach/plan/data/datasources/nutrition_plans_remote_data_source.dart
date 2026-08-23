import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_meal_model.dart';
import 'package:athletica/features/coach/plan/data/models/nutrition_plan_model.dart';
import 'package:dio/dio.dart';

typedef NutritionPlansPage = (
  {
    List<NutritionPlanModel> plans,
    ApiPagination pagination
  }
);

abstract class NutritionPlansRemoteDataSource {
  Future<NutritionPlansPage> getNutritionPlans({
    int page = 1,
    int pageSize = 20,
    String? clientId,
    bool? isActive,
  });

  Future<NutritionPlanModel> getNutritionPlan(String planId);

  Future<void> deleteNutritionPlan(String planId);

  Future<NutritionTemplateMealModel> addPlanMeal(
    String planId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  });

  Future<void> updatePlanMeal(
    String planId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  });

  Future<void> deletePlanMeal(String planId, String mealId);

  Future<void> reorderPlanMeals(
    String planId,
    List<({String mealId, int mealOrder})> mealOrders,
  );

  Future<void> addPlanFood(
    String planId,
    String mealId, {
    required String foodId,
    required num quantity,
  });

  Future<void> updatePlanFood(
    String planId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  });

  Future<void> removePlanFood(
    String planId,
    String mealId,
    String relationFoodId,
  );
}

class NutritionPlansRemoteDataSourceImpl
    implements NutritionPlansRemoteDataSource {
  const NutritionPlansRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['plan'];
      if (inner is Map<String, dynamic>) return inner;
      final meal = data['meal'];
      if (meal is Map<String, dynamic>) return meal;
      return data;
    }
    return {};
  }

  @override
  Future<NutritionPlansPage> getNutritionPlans({
    int page = 1,
    int pageSize = 20,
    String? clientId,
    bool? isActive,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.nutritionPlans,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (clientId != null && clientId.isNotEmpty) 'client_id': clientId,
        if (isActive != null) 'is_active': isActive.toString(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    final plans = (data['plans'] as List<dynamic>? ?? [])
        .map((e) => NutritionPlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = ApiPagination.fromJson(
      data['pagination'] as Map<String, dynamic>? ?? {},
    );
    return (plans: plans, pagination: pagination);
  }

  @override
  Future<NutritionPlanModel> getNutritionPlan(String planId) async {
    final response = await _dio.get(ApiEndpoints.nutritionPlan(planId));
    return NutritionPlanModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<void> deleteNutritionPlan(String planId) async {
    await _dio.delete(ApiEndpoints.nutritionPlan(planId));
  }

  @override
  Future<NutritionTemplateMealModel> addPlanMeal(
    String planId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.nutritionPlanMeals(planId),
      data: {
        'meal_type': mealType,
        'meal_order': ?mealOrder,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return NutritionTemplateMealModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<void> updatePlanMeal(
    String planId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  }) async {
    await _dio.put(
      ApiEndpoints.nutritionPlanMeal(planId, mealId),
      data: {
        'meal_type': ?mealType,
        'meal_order': ?mealOrder,
        'notes': ?notes,
      },
    );
  }

  @override
  Future<void> deletePlanMeal(String planId, String mealId) async {
    await _dio.delete(ApiEndpoints.nutritionPlanMeal(planId, mealId));
  }

  @override
  Future<void> reorderPlanMeals(
    String planId,
    List<({String mealId, int mealOrder})> mealOrders,
  ) async {
    await _dio.put(
      ApiEndpoints.nutritionPlanMealsReorder(planId),
      data: {
        'meal_orders': mealOrders
            .map((m) => {'meal_id': m.mealId, 'meal_order': m.mealOrder})
            .toList(),
      },
    );
  }

  @override
  Future<void> addPlanFood(
    String planId,
    String mealId, {
    required String foodId,
    required num quantity,
  }) async {
    await _dio.post(
      ApiEndpoints.nutritionPlanMealFoods(planId, mealId),
      data: {'food_id': foodId, 'quantity': quantity},
    );
  }

  @override
  Future<void> updatePlanFood(
    String planId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  }) async {
    await _dio.put(
      ApiEndpoints.nutritionPlanMealFood(planId, mealId, relationFoodId),
      data: {'quantity': quantity},
    );
  }

  @override
  Future<void> removePlanFood(
    String planId,
    String mealId,
    String relationFoodId,
  ) async {
    await _dio.delete(
      ApiEndpoints.nutritionPlanMealFood(planId, mealId, relationFoodId),
    );
  }
}
