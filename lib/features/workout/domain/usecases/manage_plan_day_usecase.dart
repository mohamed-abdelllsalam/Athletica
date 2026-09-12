import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';

class ManagePlanDayUseCase {
  const ManagePlanDayUseCase(this._repository);
  final WorkoutRepository _repository;

  Future<ApiResult<WorkoutPlanEntry>> create(
    String planId,
    String title, {
    String? note,
  }) =>
      _repository.createPlanDay(planId, title: title, note: note);

  Future<ApiResult<WorkoutPlanEntry>> update(
    String planId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  }) =>
      _repository.updatePlanDay(
        planId,
        dayId,
        title: title,
        dayNumber: dayNumber,
        isRest: isRest,
        note: note,
      );

  Future<ApiResult<WorkoutPlanEntry>> delete(String planId, String dayId) =>
      _repository.deletePlanDay(planId, dayId);

  Future<ApiResult<WorkoutPlanEntry>> reorder(
    String planId,
    List<String> dayIds,
  ) =>
      _repository.reorderPlanDays(planId, dayIds);
}
