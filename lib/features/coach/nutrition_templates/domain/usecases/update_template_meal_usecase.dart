import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class UpdateTemplateMealUseCase {
  const UpdateTemplateMealUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(
    String templateId,
    String mealId, {
    String? mealType,
    int? mealOrder,
    String? notes,
  }) =>
      _repository.updateTemplateMeal(
        templateId,
        mealId,
        mealType: mealType,
        mealOrder: mealOrder,
        notes: notes,
      );
}
