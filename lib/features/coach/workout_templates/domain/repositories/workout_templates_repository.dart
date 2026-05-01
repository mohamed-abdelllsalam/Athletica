import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_day.dart';
import 'package:athletica/features/coach/workout_templates/domain/entities/workout_template_item.dart';

abstract class WorkoutTemplatesRepository {
  Future<ApiResult<WorkoutTemplate>> createWorkoutTemplate({
    required String trainerId,
    required String title,
    required String level,
  });

  Future<ApiResult<List<WorkoutTemplate>>> getWorkoutTemplates(
    String trainerId,
  );

  Future<ApiResult<WorkoutTemplateDay>> createWorkoutTemplateDay({
    required String workoutTemplateId,
    required int dayIndex,
    required String label,
  });

  Future<ApiResult<WorkoutTemplateDay>> getWorkoutTemplateDayById(
    String dayId,
  );

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
  });
}
