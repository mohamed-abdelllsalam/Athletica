import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_day.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class CreateNutritionTemplateDayUseCase {
  const CreateNutritionTemplateDayUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<NutritionTemplateDay>> call({
    required String templateId,
    required String name,
    required int dayNumber,
  }) =>
      _repository.createNutritionTemplateDay(
        templateId: templateId,
        name: name,
        dayNumber: dayNumber,
      );
}
