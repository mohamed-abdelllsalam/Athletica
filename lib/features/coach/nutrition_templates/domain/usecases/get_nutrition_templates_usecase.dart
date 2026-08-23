import 'package:athletica/features/coach/nutrition_templates/domain/repositories/nutrition_templates_repository.dart';

class GetNutritionTemplatesUseCase {
  const GetNutritionTemplatesUseCase(this._repository);

  final NutritionTemplatesRepository _repository;

  Future<TemplatesPageResult> call({int page = 1, int pageSize = 20}) =>
      _repository.getNutritionTemplates(page: page, pageSize: pageSize);
}
