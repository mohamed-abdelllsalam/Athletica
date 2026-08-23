import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class AddTemplateFoodUseCase {
  const AddTemplateFoodUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(
    String templateId,
    String mealId, {
    required String foodId,
    required num quantity,
  }) =>
      _repository.addTemplateFood(
        templateId,
        mealId,
        foodId: foodId,
        quantity: quantity,
      );
}
