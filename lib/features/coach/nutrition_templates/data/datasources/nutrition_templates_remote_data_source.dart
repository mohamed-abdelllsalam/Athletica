import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_day_model.dart';
import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_item_model.dart';
import 'package:athletica/features/coach/nutrition_templates/data/models/nutrition_template_model.dart';
import 'package:dio/dio.dart';

abstract class NutritionTemplatesRemoteDataSource {
  Future<List<NutritionTemplateModel>> getNutritionTemplates();

  Future<NutritionTemplateModel> createNutritionTemplate({
    required String title,
    required String description,
    required bool isPublic,
    required int dailyTargetCalories,
    required int dailyTargetProtein,
    required int dailyTargetCarbs,
    required int dailyTargetFats,
  });

  Future<NutritionTemplateDayModel> createNutritionTemplateDay({
    required String templateId,
    required String name,
    required int dayNumber,
  });

  Future<NutritionTemplateItemModel> createNutritionTemplateItem({
    required String dayId,
    required String foodId,
    required int grams,
  });
}

class NutritionTemplatesRemoteDataSourceImpl
    implements NutritionTemplatesRemoteDataSource {
  const NutritionTemplatesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<NutritionTemplateModel>> getNutritionTemplates() async {
    final response = await _dio.get(
      ApiEndpoints.mealTemplates,
      queryParameters: {'limit': 100, 'sort': 'updatedAt', 'order': 'desc'},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) =>
            NutritionTemplateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NutritionTemplateModel> createNutritionTemplate({
    required String title,
    required String description,
    required bool isPublic,
    required int dailyTargetCalories,
    required int dailyTargetProtein,
    required int dailyTargetCarbs,
    required int dailyTargetFats,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.mealTemplates,
      data: {
        'title': title,
        'description': description,
        'isPublic': isPublic,
        'dailyTargetCalories': dailyTargetCalories,
        'dailyTargetProtein': dailyTargetProtein,
        'dailyTargetCarbs': dailyTargetCarbs,
        'dailyTargetFats': dailyTargetFats,
      },
    );
    return NutritionTemplateModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<NutritionTemplateDayModel> createNutritionTemplateDay({
    required String templateId,
    required String name,
    required int dayNumber,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.mealTemplateDays(templateId),
      data: {'name': name, 'dayIndex': dayNumber},
    );
    return NutritionTemplateDayModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<NutritionTemplateItemModel> createNutritionTemplateItem({
    required String dayId,
    required String foodId,
    required int grams,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.mealTemplateItems(dayId),
      data: {'foodId': foodId, 'grams': grams},
    );
    return NutritionTemplateItemModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
