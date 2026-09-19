import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/features/coach/nutrition_templates/data/models/assigned_client_model.dart';
import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_meal_model.dart';
import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_model.dart';
import 'package:dio/dio.dart';

typedef TemplatesPage = (
  {
    List<NutritionTemplateModel> templates,
    ApiPagination pagination
  }
);

abstract class NutritionTemplatesRemoteDataSource {
  Future<TemplatesPage> getNutritionTemplates({
    int page = 1,
    int pageSize = 20,
  });

  Future<NutritionTemplateModel> createNutritionTemplate({
    required String title,
    required String description,
  });

  Future<NutritionTemplateModel> getNutritionTemplate(String templateId);

  Future<void> updateNutritionTemplate(
    String templateId, {
    String? title,
    String? description,
  });

  Future<void> deleteNutritionTemplate(String templateId);

  Future<NutritionTemplateMealModel> addTemplateMeal(
    String templateId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  });

  Future<void> updateTemplateMeal(
    String templateId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  });

  Future<void> deleteTemplateMeal(String templateId, String mealId);

  Future<void> reorderTemplateMeals(
    String templateId,
    List<({String mealId, int mealOrder})> mealOrders,
  );

  Future<void> addTemplateFood(
    String templateId,
    String mealId, {
    required String foodId,
    required num quantity,
  });

  Future<void> updateTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  });

  Future<void> removeTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId,
  );

  Future<void> assignNutritionTemplate(
    String templateId, {
    required String coachClientId,
    required String title,
    required String description,
  });

  Future<List<AssignedClientModel>> getAssignedClients();

  /// [clientId] is the `client_profiles.id` (DELETE path param).
  Future<void> removeAssignedClient(String clientId);
}

class NutritionTemplatesRemoteDataSourceImpl
    implements NutritionTemplatesRemoteDataSource {
  const NutritionTemplatesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data['template'];
      if (inner is Map<String, dynamic>) return inner;
      return data;
    }
    return {};
  }

  @override
  Future<TemplatesPage> getNutritionTemplates({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.nutritionTemplates,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = response.data as Map<String, dynamic>;
    final templates = (data['templates'] as List<dynamic>? ?? [])
        .map((e) =>
            NutritionTemplateModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = ApiPagination.fromJson(
      data['pagination'] as Map<String, dynamic>? ?? {},
    );
    return (templates: templates, pagination: pagination);
  }

  @override
  Future<NutritionTemplateModel> createNutritionTemplate({
    required String title,
    required String description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.nutritionTemplates,
      data: {'title': title, 'description': description},
    );
    return NutritionTemplateModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<NutritionTemplateModel> getNutritionTemplate(String templateId) async {
    final response =
        await _dio.get(ApiEndpoints.nutritionTemplate(templateId));
    return NutritionTemplateModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<void> updateNutritionTemplate(
    String templateId, {
    String? title,
    String? description,
  }) async {
    await _dio.put(
      ApiEndpoints.nutritionTemplate(templateId),
      data: {
        'title': ?title,
        'description': ?description,
      },
    );
  }

  @override
  Future<void> deleteNutritionTemplate(String templateId) async {
    await _dio.delete(ApiEndpoints.nutritionTemplate(templateId));
  }

  @override
  Future<NutritionTemplateMealModel> addTemplateMeal(
    String templateId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.nutritionTemplateMeals(templateId),
      data: {
        'meal_type': mealType,
        'meal_order': ?mealOrder,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final meal = data['meal'];
    return NutritionTemplateMealModel.fromJson(
      meal is Map<String, dynamic> ? meal : {},
    );
  }

  @override
  Future<void> updateTemplateMeal(
    String templateId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  }) async {
    await _dio.put(
      ApiEndpoints.nutritionTemplateMeal(templateId, mealId),
      data: {
        'meal_type': ?mealType,
        'meal_order': ?mealOrder,
        'notes': ?notes,
      },
    );
  }

  @override
  Future<void> deleteTemplateMeal(String templateId, String mealId) async {
    await _dio.delete(ApiEndpoints.nutritionTemplateMeal(templateId, mealId));
  }

  @override
  Future<void> reorderTemplateMeals(
    String templateId,
    List<({String mealId, int mealOrder})> mealOrders,
  ) async {
    await _dio.put(
      ApiEndpoints.nutritionTemplateMealsReorder(templateId),
      data: {
        'meal_orders': mealOrders
            .map((m) => {'meal_id': m.mealId, 'meal_order': m.mealOrder})
            .toList(),
      },
    );
  }

  @override
  Future<void> addTemplateFood(
    String templateId,
    String mealId, {
    required String foodId,
    required num quantity,
  }) async {
    await _dio.post(
      ApiEndpoints.nutritionTemplateMealFoods(templateId, mealId),
      data: {'food_id': foodId, 'quantity': quantity},
    );
  }

  @override
  Future<void> updateTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  }) async {
    await _dio.put(
      ApiEndpoints.nutritionTemplateMealFood(
          templateId, mealId, relationFoodId),
      data: {'quantity': quantity},
    );
  }

  @override
  Future<void> removeTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId,
  ) async {
    await _dio.delete(
      ApiEndpoints.nutritionTemplateMealFood(
          templateId, mealId, relationFoodId),
    );
  }

  @override
  Future<void> assignNutritionTemplate(
    String templateId, {
    required String coachClientId,
    required String title,
    required String description,
  }) async {
    await _dio.post(
      ApiEndpoints.assignNutritionTemplate(templateId),
      data: {
        'coach_client_id': coachClientId,
        'title': title,
        'description': description,
      },
    );
  }

  @override
  Future<List<AssignedClientModel>> getAssignedClients() async {
    final response = await _dio.get(ApiEndpoints.coachClients);
    final data = response.data as Map<String, dynamic>;
    return (data['clients'] as List<dynamic>? ?? [])
        .map((e) => AssignedClientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> removeAssignedClient(String clientId) async {
    await _dio.delete(ApiEndpoints.coachClient(clientId));
  }
}
