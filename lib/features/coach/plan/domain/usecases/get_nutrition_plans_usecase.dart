import 'package:athletica/features/coach/plan/domain/repositories/nutrition_plans_repository.dart';

class GetNutritionPlansUseCase {
  const GetNutritionPlansUseCase(this._repository);

  final NutritionPlansRepository _repository;

  Future<NutritionPlansPageResult> call({
    int page = 1,
    int pageSize = 20,
    String? clientId,
    bool? isActive,
  }) =>
      _repository.getNutritionPlans(
        page: page,
        pageSize: pageSize,
        clientId: clientId,
        isActive: isActive,
      );
}
