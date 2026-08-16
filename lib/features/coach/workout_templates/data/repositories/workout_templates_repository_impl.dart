import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/workout_templates/data/datasources/workout_templates_remote_data_source.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_day.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_item.dart';
import 'package:athletica/features/coach/workout_templates/domain/repositories/workout_templates_repository.dart';
import 'package:dio/dio.dart';

class WorkoutTemplatesRepositoryImpl implements WorkoutTemplatesRepository {
  const WorkoutTemplatesRepositoryImpl(this._dataSource);

  final WorkoutTemplatesRemoteDataSource _dataSource;

  @override
  Future<ApiResult<WorkoutTemplate>> createWorkoutTemplate({
    required String trainerId,
    required String title,
    required String level,
  }) async {
    try {
      final model = await _dataSource.createWorkoutTemplate(
        trainerId: trainerId,
        title: title,
        level: level,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<WorkoutTemplate>>> getWorkoutTemplates(
    String trainerId,
  ) async {
    try {
      final models = await _dataSource.getWorkoutTemplates(trainerId);
      return ApiSuccess(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkoutTemplateDay>> createWorkoutTemplateDay({
    required String workoutTemplateId,
    required int dayIndex,
    required String label,
  }) async {
    try {
      final model = await _dataSource.createWorkoutTemplateDay(
        workoutTemplateId: workoutTemplateId,
        dayIndex: dayIndex,
        label: label,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkoutTemplateDay>> getWorkoutTemplateDayById(
    String dayId,
  ) async {
    try {
      final model = await _dataSource.getWorkoutTemplateDayById(dayId);
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkoutTemplateItem>> createWorkoutTemplateItem({
    required String workoutTemplateDayId,
    required String exerciseId,
    required int order,
    required int sets,
    required int reps,
    required int restSeconds,
    String? notes,
    String? tempo,
    int? rir,
    int? rpe,
  }) async {
    try {
      final model = await _dataSource.createWorkoutTemplateItem(
        workoutTemplateDayId: workoutTemplateDayId,
        exerciseId: exerciseId,
        order: order,
        sets: sets,
        reps: reps,
        restSeconds: restSeconds,
        notes: notes,
        tempo: tempo,
        rir: rir,
        rpe: rpe,
      );
      return ApiSuccess(model.toEntity());
    } on DioException catch (e) {
      return ApiError(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return ApiError(UnknownFailure(e.toString()));
    }
  }
}
