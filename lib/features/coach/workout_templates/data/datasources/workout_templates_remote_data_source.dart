import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/coach/workout_templates/data/models/workout_template_day_model.dart';
import 'package:athletica/features/coach/workout_templates/data/models/workout_template_item_model.dart';
import 'package:athletica/features/coach/workout_templates/data/models/workout_template_model.dart';
import 'package:dio/dio.dart';

abstract class WorkoutTemplatesRemoteDataSource {
  Future<WorkoutTemplateModel> createWorkoutTemplate({
    required String trainerId,
    required String title,
    required String level,
  });

  Future<List<WorkoutTemplateModel>> getWorkoutTemplates(String trainerId);

  Future<WorkoutTemplateDayModel> createWorkoutTemplateDay({
    required String workoutTemplateId,
    required int dayIndex,
    required String label,
  });

  Future<WorkoutTemplateDayModel> getWorkoutTemplateDayById(String dayId);

  Future<WorkoutTemplateItemModel> createWorkoutTemplateItem({
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

class WorkoutTemplatesRemoteDataSourceImpl
    implements WorkoutTemplatesRemoteDataSource {
  const WorkoutTemplatesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<WorkoutTemplateModel> createWorkoutTemplate({
    required String trainerId,
    required String title,
    required String level,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.createWorkoutTemplate,
      data: {'trainerId': trainerId, 'title': title, 'level': level},
    );
    return WorkoutTemplateModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<WorkoutTemplateModel>> getWorkoutTemplates(
    String trainerId,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.workoutTemplates(trainerId),
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => WorkoutTemplateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WorkoutTemplateDayModel> createWorkoutTemplateDay({
    required String workoutTemplateId,
    required int dayIndex,
    required String label,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workoutTemplateDays,
      data: {
        'workoutTemplateId': workoutTemplateId,
        'dayIndex': dayIndex,
        'label': label,
      },
    );
    return WorkoutTemplateDayModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<WorkoutTemplateDayModel> getWorkoutTemplateDayById(
    String dayId,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.workoutTemplateDayById(dayId),
    );
    return WorkoutTemplateDayModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<WorkoutTemplateItemModel> createWorkoutTemplateItem({
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
    final response = await _dio.post(
      ApiEndpoints.workoutTemplateItems,
      data: {
        'workoutTemplateDayId': workoutTemplateDayId,
        'exerciseId': exerciseId,
        'order': order,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
        'notes': notes,
        'tempo': tempo,
        'rir': rir,
        'rpe': rpe,
      },
    );
    return WorkoutTemplateItemModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
