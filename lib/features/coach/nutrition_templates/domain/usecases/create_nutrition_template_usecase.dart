import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class CreateNutritionTemplateUseCase {
  const CreateNutritionTemplateUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<NutritionTemplate>> call({
    required String title,
    required String description,
  }) =>
      _repository.createNutritionTemplate(title: title, description: description);
}
