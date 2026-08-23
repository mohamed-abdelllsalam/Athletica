import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class DeleteNutritionTemplateUseCase {
  const DeleteNutritionTemplateUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(String templateId) =>
      _repository.deleteNutritionTemplate(templateId);
}
