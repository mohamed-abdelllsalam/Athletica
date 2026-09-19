import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';

typedef TemplatesPageResult =
    ApiResult<({List<NutritionTemplate> templates, ApiPagination pagination})>;

abstract class NutritionTemplatesRepository {
  Future<TemplatesPageResult> getNutritionTemplates({
    int page = 1,
    int pageSize = 20,
  });

  Future<ApiResult<NutritionTemplate>> createNutritionTemplate({
    required String title,
    required String description,
  });

  Future<ApiResult<NutritionTemplate>> getNutritionTemplate(String templateId);

  Future<ApiResult<void>> updateNutritionTemplate(
    String templateId, {
    String? title,
    String? description,
  });

  Future<ApiResult<void>> deleteNutritionTemplate(String templateId);

  Future<ApiResult<NutritionTemplateMeal>> addTemplateMeal(
    String templateId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  });

  Future<ApiResult<void>> updateTemplateMeal(
    String templateId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  });

  Future<ApiResult<void>> deleteTemplateMeal(String templateId, String mealId);

  Future<ApiResult<void>> reorderTemplateMeals(
    String templateId,
    List<({String mealId, int mealOrder})> mealOrders,
  );

  Future<ApiResult<void>> addTemplateFood(
    String templateId,
    String mealId, {
    required String foodId,
    required num quantity,
  });

  Future<ApiResult<void>> updateTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId, {
    required num quantity,
  });

  Future<ApiResult<void>> removeTemplateFood(
    String templateId,
    String mealId,
    String relationFoodId,
  );

  Future<ApiResult<void>> assignNutritionTemplate(
    String templateId, {
    required String coachClientId,
    required String title,
    required String description,
  });

  Future<ApiResult<List<AssignedClient>>> getAssignedClients();

  /// Removes the coach-client relationship (`DELETE /coach/clients/:id`).
  /// [clientId] is the `client_profiles.id` (DELETE path param).
  /// Cascades: deletes all nutrition plans, meals, meal logs and workout data
  /// for that client.
  Future<ApiResult<void>> removeAssignedClient(String clientId);
}
