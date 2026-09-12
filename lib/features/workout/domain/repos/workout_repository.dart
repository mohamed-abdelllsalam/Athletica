import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/workout/domain/entities/workout_history.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';

abstract class WorkoutRepository {
  // ── Exercise library ──
  Future<ApiResult<({List<WorkoutExerciseEntry> items, ApiPagination pagination})>>
      getExercises(WorkoutExerciseFilters filters);
  Future<ApiResult<WorkoutExerciseEntry>> getExercise(String id);

  // ── Templates ──
  Future<ApiResult<WorkoutTemplateEntry>> createTemplate({
    required String title,
    required String description,
  });
  Future<ApiResult<({List<WorkoutTemplateEntry> items, ApiPagination pagination})>>
      getTemplates({int page = 1, int pageSize = 10});
  Future<ApiResult<WorkoutTemplateEntry>> getTemplate(String templateId);
  Future<ApiResult<WorkoutTemplateEntry>> updateTemplate(
    String templateId, {
    String? title,
    String? description,
  });
  Future<ApiResult<void>> deleteTemplate(String templateId);

  // ── Template days ──
  Future<ApiResult<WorkoutTemplateEntry>> createTemplateDay(
    String templateId, {
    required String title,
    String? note,
  });
  Future<ApiResult<WorkoutTemplateEntry>> updateTemplateDay(
    String templateId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  });
  Future<ApiResult<WorkoutTemplateEntry>> deleteTemplateDay(
    String templateId,
    String dayId,
  );
  Future<ApiResult<WorkoutTemplateEntry>> reorderTemplateDays(
    String templateId,
    List<String> dayIds,
  );

  // ── Template exercises ──
  Future<ApiResult<WorkoutTemplateEntry>> addTemplateExercise(
    String templateId,
    String dayId, {
    required String exerciseId,
    int? exerciseOrder,
    String? notes,
  });
  Future<ApiResult<WorkoutTemplateEntry>> updateTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId, {
    int? exerciseOrder,
    String? notes,
  });
  Future<ApiResult<WorkoutTemplateEntry>> deleteTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId,
  );

  // ── Assign ──
  Future<ApiResult<WorkoutPlanEntry>> assignTemplate(
    String templateId, {
    required String coachClientId,
    String? title,
    String? description,
  });

  // ── Plans ──
  Future<ApiResult<({List<WorkoutPlanSummary> items, ApiPagination pagination})>>
      getPlans({
    required String clientId,
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });
  Future<ApiResult<WorkoutPlanEntry>> getPlan(String planId);
  Future<ApiResult<WorkoutPlanEntry>> updatePlan(
    String planId, {
    String? title,
    String? description,
  });
  Future<ApiResult<void>> deletePlan(String planId);

  // ── Plan days ──
  Future<ApiResult<WorkoutPlanEntry>> createPlanDay(
    String planId, {
    required String title,
    String? note,
  });
  Future<ApiResult<WorkoutPlanEntry>> updatePlanDay(
    String planId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  });
  Future<ApiResult<WorkoutPlanEntry>> deletePlanDay(
    String planId,
    String dayId,
  );
  Future<ApiResult<WorkoutPlanEntry>> reorderPlanDays(
    String planId,
    List<String> dayIds,
  );

  // ── Plan exercises ──
  Future<ApiResult<WorkoutPlanEntry>> addPlanExercise(
    String planId,
    String dayId, {
    required String exerciseId,
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  });
  Future<ApiResult<WorkoutPlanEntry>> updatePlanExercise(
    String planId,
    String dayId,
    String exerciseId, {
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  });
  Future<ApiResult<WorkoutPlanEntry>> deletePlanExercise(
    String planId,
    String dayId,
    String exerciseId,
  );

  // ── Client ──
  Future<ApiResult<TodayWorkoutEntry?>> getTodayWorkout();
  Future<ApiResult<ExerciseCompletionResult>> completeExercise(String logId);
  Future<ApiResult<ExerciseCompletionResult>> uncompleteExercise(String logId);
  Future<ApiResult<WorkoutPlanEntry?>> getMyActivePlan();
  Future<ApiResult<WorkoutPlanEntry>> getMyPlanDetails(String planId);
  Future<ApiResult<List<WorkoutHistoryDay>>> getHistory();
}
