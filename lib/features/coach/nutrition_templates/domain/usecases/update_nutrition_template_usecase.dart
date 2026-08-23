import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class UpdateNutritionTemplateUseCase {
  const UpdateNutritionTemplateUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(
    String templateId, {
    String? title,
    String? description,
  }) =>
      _repository.updateNutritionTemplate(
        templateId,
        title: title,
        description: description,
      );
}
