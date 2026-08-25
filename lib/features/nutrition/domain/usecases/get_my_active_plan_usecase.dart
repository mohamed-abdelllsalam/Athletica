import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/my_plan.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';

class GetMyActivePlanUseCase {
  const GetMyActivePlanUseCase(this._repository);

  final NutritionRepository _repository;

  /// Returns null data when the client has no active plan.
  Future<ApiResult<MyPlan?>> call() => _repository.getMyActivePlan();
}
