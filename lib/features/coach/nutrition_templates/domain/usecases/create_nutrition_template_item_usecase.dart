import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template_item.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class CreateNutritionTemplateItemUseCase {
  const CreateNutritionTemplateItemUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<NutritionTemplateItem>> call({
    required String dayId,
    required String foodId,
    required int grams,
  }) =>
      _repository.createNutritionTemplateItem(
        dayId: dayId,
        foodId: foodId,
        grams: grams,
      );
}
