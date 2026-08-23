import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class ReorderTemplateMealsUseCase {
  const ReorderTemplateMealsUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<ApiResult<void>> call(
    String templateId,
    List<({String mealId, int mealOrder})> mealOrders,
  ) =>
      _repository.reorderTemplateMeals(templateId, mealOrders);
}
