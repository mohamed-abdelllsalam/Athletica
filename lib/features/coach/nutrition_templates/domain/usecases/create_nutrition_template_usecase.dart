import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class CreateNutritionTemplateUseCase {
  const CreateNutritionTemplateUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<NutritionTemplate>> call({
    required String title,
    required String description,
    required bool isPublic,
    required int dailyTargetCalories,
    required int dailyTargetProtein,
    required int dailyTargetCarbs,
    required int dailyTargetFats,
  }) =>
      _repository.createNutritionTemplate(
        title: title,
        description: description,
        isPublic: isPublic,
        dailyTargetCalories: dailyTargetCalories,
        dailyTargetProtein: dailyTargetProtein,
        dailyTargetCarbs: dailyTargetCarbs,
        dailyTargetFats: dailyTargetFats,
      );
}
