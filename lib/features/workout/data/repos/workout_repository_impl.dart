import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/workout/data/datasources/workout_remote_data_source.dart';
import 'package:athletica/features/workout/domain/entities/today_workout.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/workout/domain/entities/workout_history.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/repos/workout_repository.dart';
import 'package:dio/dio.dart';

/// Boundary: catches Dio errors here and maps to typed failures.
/// Never lets raw exceptions leak into domain/presentation.
class WorkoutRepositoryImpl implements WorkoutRepository {
  const WorkoutRepositoryImpl(this._dataSource);

  final WorkoutRemoteDataSource _dataSource;

  Future<ApiResult<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return ApiSuccess(await run());
    } on DioException catch (e) {
      return ApiError(mapDioException(e));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<({List<WorkoutExerciseEntry> items, ApiPagination pagination})>>
      getExercises(WorkoutExerciseFilters filters) => _guard(() async {
            final page = await _dataSource.getExercises(filters);
            return (
              items: page.exercises.map((e) => e.toEntity()).toList(),
              pagination: page.pagination,
            );
          });

  @override
  Future<ApiResult<WorkoutExerciseEntry>> getExercise(String id) =>
      _guard(() async => (await _dataSource.getExercise(id)).toEntity());

  @override
  Future<ApiResult<WorkoutTemplateEntry>> createTemplate({
    required String title,
    required String description,
  }) =>
      _guard(
        () async =>
            (await _dataSource.createTemplate(title: title, description: description))
                .toEntity(),
      );

  @override
  Future<ApiResult<({List<WorkoutTemplateEntry> items, ApiPagination pagination})>>
      getTemplates({int page = 1, int pageSize = 10}) => _guard(() async {
            final res = await _dataSource.getTemplates(page: page, pageSize: pageSize);
            return (
              items: res.templates.map((e) => e.toEntity()).toList(),
              pagination: res.pagination,
            );
          });

  @override
  Future<ApiResult<WorkoutTemplateEntry>> getTemplate(String templateId) =>
      _guard(() async => (await _dataSource.getTemplate(templateId)).toEntity());

  @override
  Future<ApiResult<WorkoutTemplateEntry>> updateTemplate(
    String templateId, {
    String? title,
    String? description,
  }) =>
      _guard(
        () async => (await _dataSource.updateTemplate(
          templateId,
          title: title,
          description: description,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<void>> deleteTemplate(String templateId) => _guard(() async {
        await _dataSource.deleteTemplate(templateId);
      });

  @override
  Future<ApiResult<WorkoutTemplateEntry>> createTemplateDay(
    String templateId, {
    required String title,
    String? note,
  }) =>
      _guard(
        () async => (await _dataSource.createTemplateDay(
          templateId,
          title: title,
          note: note,
        )).toEntity(),
      );

  @override
  Future<ApiResult<WorkoutTemplateEntry>> updateTemplateDay(
    String templateId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  }) =>
      _guard(
        () async => (await _dataSource.updateTemplateDay(
          templateId,
          dayId,
          title: title,
          dayNumber: dayNumber,
          isRest: isRest,
          note: note,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<WorkoutTemplateEntry>> deleteTemplateDay(
    String templateId,
    String dayId,
  ) =>
      _guard(
        () async =>
            (await _dataSource.deleteTemplateDay(templateId, dayId)).toEntity(),
      );

  @override
  Future<ApiResult<WorkoutTemplateEntry>> reorderTemplateDays(
    String templateId,
    List<String> dayIds,
  ) =>
      _guard(
        () async =>
            (await _dataSource.reorderTemplateDays(templateId, dayIds)).toEntity(),
      );

  @override
  Future<ApiResult<WorkoutTemplateEntry>> addTemplateExercise(
    String templateId,
    String dayId, {
    required String exerciseId,
    int? exerciseOrder,
    String? notes,
  }) =>
      _guard(
        () async => (await _dataSource.addTemplateExercise(
          templateId,
          dayId,
          exerciseId: exerciseId,
          exerciseOrder: exerciseOrder,
          notes: notes,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<WorkoutTemplateEntry>> updateTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId, {
    int? exerciseOrder,
    String? notes,
  }) =>
      _guard(
        () async => (await _dataSource.updateTemplateExercise(
          templateId,
          dayId,
          exerciseId,
          exerciseOrder: exerciseOrder,
          notes: notes,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<WorkoutTemplateEntry>> deleteTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId,
  ) =>
      _guard(
        () async => (await _dataSource.deleteTemplateExercise(
          templateId,
          dayId,
          exerciseId,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<WorkoutPlanEntry>> assignTemplate(
    String templateId, {
    required String coachClientId,
    String? title,
    String? description,
  }) =>
      _guard(
        () async => (await _dataSource.assignTemplate(
          templateId,
          coachClientId: coachClientId,
          title: title,
          description: description,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<({List<WorkoutPlanSummary> items, ApiPagination pagination})>>
      getPlans({
    required String clientId,
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) =>
          _guard(() async {
            final res = await _dataSource.getPlans(
              clientId: clientId,
              isActive: isActive,
              page: page,
              pageSize: pageSize,
            );
            return (
              items: res.plans.map((e) => e.toEntity()).toList(),
              pagination: res.pagination,
            );
          });

  @override
  Future<ApiResult<WorkoutPlanEntry>> getPlan(String planId) =>
      _guard(() async => (await _dataSource.getPlan(planId)).toEntity());

  @override
  Future<ApiResult<WorkoutPlanEntry>> updatePlan(
    String planId, {
    String? title,
    String? description,
  }) =>
      _guard(
        () async => (await _dataSource.updatePlan(
          planId,
          title: title,
          description: description,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<void>> deletePlan(String planId) => _guard(() async {
        await _dataSource.deletePlan(planId);
      });

  @override
  Future<ApiResult<WorkoutPlanEntry>> createPlanDay(
    String planId, {
    required String title,
    String? note,
  }) =>
      _guard(
        () async => (await _dataSource.createPlanDay(
          planId,
          title: title,
          note: note,
        )).toEntity(),
      );

  @override
  Future<ApiResult<WorkoutPlanEntry>> updatePlanDay(
    String planId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  }) =>
      _guard(
        () async => (await _dataSource.updatePlanDay(
          planId,
          dayId,
          title: title,
          dayNumber: dayNumber,
          isRest: isRest,
          note: note,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<WorkoutPlanEntry>> deletePlanDay(
    String planId,
    String dayId,
  ) =>
      _guard(
        () async => (await _dataSource.deletePlanDay(planId, dayId)).toEntity(),
      );

  @override
  Future<ApiResult<WorkoutPlanEntry>> reorderPlanDays(
    String planId,
    List<String> dayIds,
  ) =>
      _guard(
        () async =>
            (await _dataSource.reorderPlanDays(planId, dayIds)).toEntity(),
      );

  @override
  Future<ApiResult<WorkoutPlanEntry>> addPlanExercise(
    String planId,
    String dayId, {
    required String exerciseId,
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) =>
      _guard(
        () async => (await _dataSource.addPlanExercise(
          planId,
          dayId,
          exerciseId: exerciseId,
          orderNumber: orderNumber,
          sets: sets,
          reps: reps,
          restTime: restTime,
          notes: notes,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<WorkoutPlanEntry>> updatePlanExercise(
    String planId,
    String dayId,
    String exerciseId, {
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) =>
      _guard(
        () async => (await _dataSource.updatePlanExercise(
          planId,
          dayId,
          exerciseId,
          orderNumber: orderNumber,
          sets: sets,
          reps: reps,
          restTime: restTime,
          notes: notes,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<WorkoutPlanEntry>> deletePlanExercise(
    String planId,
    String dayId,
    String exerciseId,
  ) =>
      _guard(
        () async => (await _dataSource.deletePlanExercise(
          planId,
          dayId,
          exerciseId,
        ))
            .toEntity(),
      );

  @override
  Future<ApiResult<TodayWorkoutEntry?>> getTodayWorkout() => _guard(() async {
        final model = await _dataSource.getTodayWorkout();
        return model?.toEntity();
      });

  @override
  Future<ApiResult<ExerciseCompletionResult>> completeExercise(String logId) =>
      _guard(() async => await _dataSource.completeExercise(logId));

  @override
  Future<ApiResult<ExerciseCompletionResult>> uncompleteExercise(String logId) =>
      _guard(() async => await _dataSource.uncompleteExercise(logId));

  @override
  Future<ApiResult<WorkoutPlanEntry?>> getMyActivePlan() => _guard(() async {
        final model = await _dataSource.getMyActivePlan();
        return model?.toEntity();
      });

  @override
  Future<ApiResult<WorkoutPlanEntry>> getMyPlanDetails(String planId) =>
      _guard(() async => (await _dataSource.getMyPlanDetails(planId)).toEntity());

  @override
  Future<ApiResult<List<WorkoutHistoryDay>>> getHistory() => _guard(() async {
        final model = await _dataSource.getHistory();
        return model.days;
      });
}
