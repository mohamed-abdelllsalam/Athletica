import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_day.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_item.dart';

abstract class NutritionTemplatesRepository {
  Future<ApiResult<List<NutritionTemplate>>> getNutritionTemplates();

  Future<ApiResult<NutritionTemplate>> createNutritionTemplate({
    required String title,
    required String description,
    required bool isPublic,
    required int dailyTargetCalories,
    required int dailyTargetProtein,
    required int dailyTargetCarbs,
    required int dailyTargetFats,
  });

  Future<ApiResult<NutritionTemplateDay>> createNutritionTemplateDay({
    required String templateId,
    required String name,
    required int dayNumber,
  });

  Future<ApiResult<NutritionTemplateItem>> createNutritionTemplateItem({
    required String dayId,
    required String foodId,
    required int grams,
  });
}
