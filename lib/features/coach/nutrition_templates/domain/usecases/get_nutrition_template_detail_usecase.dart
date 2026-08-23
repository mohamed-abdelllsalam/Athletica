import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class GetNutritionTemplateDetailUseCase {
  const GetNutritionTemplateDetailUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<NutritionTemplate>> call(String templateId) =>
      _repository.getNutritionTemplate(templateId);
}
