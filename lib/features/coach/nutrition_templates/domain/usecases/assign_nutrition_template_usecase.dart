import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class AssignNutritionTemplateUseCase {
  const AssignNutritionTemplateUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(
    String templateId, {
    required String coachClientId,
    required String title,
    required String description,
  }) =>
      _repository.assignNutritionTemplate(
        templateId,
        coachClientId: coachClientId,
        title: title,
        description: description,
      );
}
