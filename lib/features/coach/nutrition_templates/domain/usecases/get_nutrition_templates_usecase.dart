import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class GetNutritionTemplatesUseCase {
  const GetNutritionTemplatesUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<List<NutritionTemplate>>> call() =>
      _repository.getNutritionTemplates();
}
