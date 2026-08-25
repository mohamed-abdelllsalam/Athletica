import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';

class GetMyPlanDetailsUseCase {
  const GetMyPlanDetailsUseCase(this._repository);

  final NutritionRepository _repository;

  Future<ApiResult<MyPlan>> call(String planId) =>
      _repository.getMyPlanDetails(planId);
}
