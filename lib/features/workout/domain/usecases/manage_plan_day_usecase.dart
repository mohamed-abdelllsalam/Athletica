import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class ManagePlanDayUseCase {
  const ManagePlanDayUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutPlanEntry>> create(String planId, String title) =>
      _repository.createPlanDay(planId, title: title);

  Future<ApiResult<WorkoutPlanEntry>> update(
    String planId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
  }) =>
      _repository.updatePlanDay(
        planId,
        dayId,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
      );

  Future<ApiResult<WorkoutPlanEntry>> delete(String planId, String dayId) =>
      _repository.deletePlanDay(planId, dayId);

  Future<ApiResult<WorkoutPlanEntry>> reorder(
    String planId,
    List<String> dayIds,
  ) =>
      _repository.reorderPlanDays(planId, dayIds);
}
