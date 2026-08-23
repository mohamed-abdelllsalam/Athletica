import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class AddTemplateMealUseCase {
  const AddTemplateMealUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<NutritionTemplateMeal>> call(
    String templateId, {
    required String mealType,
    int? mealOrder,
    String? notes,
  }) =>
      _repository.addTemplateMeal(
        templateId,
        mealType: mealType,
        mealOrder: mealOrder,
        notes: notes,
      );
}
