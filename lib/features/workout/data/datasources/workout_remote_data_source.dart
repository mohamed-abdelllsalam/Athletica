import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/features/workout/data/models/today_workout_model.dart';
import 'package:athletica/features/workout/data/models/workout_exercise_model.dart';
import 'package:athletica/features/workout/data/models/workout_plan_model.dart';
import 'package:athletica/features/workout/data/models/workout_template_model.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:dio/dio.dart';

typedef WorkoutExercisesPage = ({
  List<WorkoutExerciseModel> exercises,
  ApiPagination pagination,
});

typedef WorkoutTemplatesPage = ({
  List<WorkoutTemplateModel> templates,
  ApiPagination pagination,
});

typedef WorkoutPlansPage = ({
  List<WorkoutPlanSummaryModel> plans,
  ApiPagination pagination,
});

Map<String, dynamic> _dataMap(dynamic body) {
  if (body is Map<String, dynamic>) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return body;
  }
  return {};
}

abstract class WorkoutRemoteDataSource {
  // ── Exercise library ──
  Future<WorkoutExercisesPage> getExercises(WorkoutExerciseFilters filters);
  Future<WorkoutExerciseModel> getExercise(String id);

  // ── Templates ──
  Future<WorkoutTemplateModel> createTemplate({
    required String title,
    required String description,
  });
  Future<WorkoutTemplatesPage> getTemplates({int page = 1, int pageSize = 10});
  Future<WorkoutTemplateModel> getTemplate(String templateId);
  Future<WorkoutTemplateModel> updateTemplate(
    String templateId, {
    String? title,
    String? description,
  });
  Future<void> deleteTemplate(String templateId);

  // ── Template days ──
  Future<WorkoutTemplateModel> createTemplateDay(
    String templateId, {
    required String title,
    String? note,
  });
  Future<WorkoutTemplateModel> updateTemplateDay(
    String templateId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  });
  Future<WorkoutTemplateModel> deleteTemplateDay(
    String templateId,
    String dayId,
  );
  Future<WorkoutTemplateModel> reorderTemplateDays(
    String templateId,
    List<String> dayIds,
  );

  // ── Template exercises (NO sets/reps) ──
  Future<WorkoutTemplateModel> addTemplateExercise(
    String templateId,
    String dayId, {
    required String exerciseId,
    int? exerciseOrder,
    String? notes,
  });
  Future<WorkoutTemplateModel> updateTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId, {
    int? exerciseOrder,
    String? notes,
  });
  Future<WorkoutTemplateModel> deleteTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId,
  );

  // ── Assign (NO start_date — server generates Cairo today) ──
  Future<WorkoutPlanModel> assignTemplate(
    String templateId, {
    required String coachClientId,
    String? title,
    String? description,
  });

  // ── Plans (coach) ──
  Future<WorkoutPlansPage> getPlans({
    required String clientId,
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });
  Future<WorkoutPlanModel> getPlan(String planId);
  Future<WorkoutPlanModel> updatePlan(
    String planId, {
    String? title,
    String? description,
  });
  Future<void> deletePlan(String planId);

  // ── Plan days ──
  Future<WorkoutPlanModel> createPlanDay(
    String planId, {
    required String title,
    String? note,
  });
  Future<WorkoutPlanModel> updatePlanDay(
    String planId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  });
  Future<WorkoutPlanModel> deletePlanDay(String planId, String dayId);
  Future<WorkoutPlanModel> reorderPlanDays(String planId, List<String> dayIds);

  // ── Plan exercises (WITH sets/reps/rest_time) ──
  Future<WorkoutPlanModel> addPlanExercise(
    String planId,
    String dayId, {
    required String exerciseId,
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  });
  Future<WorkoutPlanModel> updatePlanExercise(
    String planId,
    String dayId,
    String exerciseId, {
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  });
  Future<WorkoutPlanModel> deletePlanExercise(
    String planId,
    String dayId,
    String exerciseId,
  );

  // ── Client ──
  Future<TodayWorkoutModel?> getTodayWorkout();
  Future<ExerciseCompletionModel> completeExercise(String logId);
  Future<ExerciseCompletionModel> uncompleteExercise(String logId);
  Future<WorkoutPlanModel?> getMyActivePlan();
  Future<WorkoutPlanModel> getMyPlanDetails(String planId);
  Future<WorkoutHistoryModel> getHistory();
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  const WorkoutRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  // DOC_6 §4.1 filter contract — removed params (primaryMuscle,
  // exerciseType, movementPattern, workoutLocation, priority, goal, tag,
  // classification, isDefault) are never sent.
  Map<String, dynamic> _query(WorkoutExerciseFilters f) => {
        if (f.search != null && f.search!.isNotEmpty) 'search': f.search,
        if (f.bodyPart != null) 'bodyPart': f.bodyPart,
        if (f.target != null) 'target': f.target,
        if (f.secondaryMuscle != null) 'secondaryMuscle': f.secondaryMuscle,
        if (f.equipment != null) 'equipment': f.equipment,
        if (f.difficulty != null) 'difficulty': f.difficulty,
        if (f.muscleGroup != null) 'muscleGroup': f.muscleGroup,
        if (f.compound != null) 'compound': '${f.compound}',
        if (f.unilateral != null) 'unilateral': '${f.unilateral}',
        'page': f.page,
        'pageSize': f.pageSize.clamp(1, 100),
      };

  @override
  Future<WorkoutExercisesPage> getExercises(
    WorkoutExerciseFilters filters,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.workoutExercises,
      queryParameters: _query(filters),
    );
    final data = _dataMap(response.data);
    final items = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(WorkoutExerciseModel.fromJson)
        .toList();
    final pagination = ApiPagination.fromJson(
      data['pagination'] as Map<String, dynamic>? ?? {},
    );
    return (exercises: items, pagination: pagination);
  }

  @override
  Future<WorkoutExerciseModel> getExercise(String id) async {
    final response = await _dio.get(ApiEndpoints.workoutExercise(id));
    final data = _dataMap(response.data);
    final exercise = data['exercise'];
    if (exercise is Map<String, dynamic>) {
      return WorkoutExerciseModel.fromJson(exercise);
    }
    return WorkoutExerciseModel.fromJson(data);
  }

  @override
  Future<WorkoutTemplateModel> createTemplate({
    required String title,
    required String description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workoutTemplatesV1,
      data: {'title': title, 'description': description},
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplatesPage> getTemplates({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.workoutTemplatesV1,
      queryParameters: {'page': page, 'pageSize': pageSize.clamp(1, 100)},
    );
    final data = _dataMap(response.data);
    // API may return `items` or `templates`.
    final raw = (data['items'] as List<dynamic>? ??
            data['templates'] as List<dynamic>? ??
            [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final templates =
        raw.map(WorkoutTemplateModel.fromJson).toList();
    final pagination = ApiPagination.fromJson(
      data['pagination'] as Map<String, dynamic>? ?? {},
    );
    return (templates: templates, pagination: pagination);
  }

  @override
  Future<WorkoutTemplateModel> getTemplate(String templateId) async {
    final response =
        await _dio.get(ApiEndpoints.workoutTemplate(templateId));
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplateModel> updateTemplate(
    String templateId, {
    String? title,
    String? description,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workoutTemplate(templateId),
      data: {'title': ?title, 'description': ?description},
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    await _dio.delete(ApiEndpoints.workoutTemplate(templateId));
  }

  @override
  Future<WorkoutTemplateModel> createTemplateDay(
    String templateId, {
    required String title,
    String? note,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workoutTemplateDaysV1(templateId),
      data: {'title': title, 'note': ?note},
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplateModel> updateTemplateDay(
    String templateId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workoutTemplateDay(templateId, dayId),
      data: {
        'title': ?title,
        'day_number': ?dayNumber,
        'is_rest': ?isRest,
        'note': ?note,
      },
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplateModel> deleteTemplateDay(
    String templateId,
    String dayId,
  ) async {
    final response = await _dio.delete(
      ApiEndpoints.workoutTemplateDay(templateId, dayId),
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplateModel> reorderTemplateDays(
    String templateId,
    List<String> dayIds,
  ) async {
    final response = await _dio.put(
      ApiEndpoints.workoutTemplateDaysReorder(templateId),
      data: {
        'day_ids': dayIds,
      },
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplateModel> addTemplateExercise(
    String templateId,
    String dayId, {
    required String exerciseId,
    int? exerciseOrder,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workoutTemplateDayExercises(templateId, dayId),
      data: {
        'exercise_id': exerciseId,
        'exercise_order': ?exerciseOrder,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplateModel> updateTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId, {
    int? exerciseOrder,
    String? notes,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workoutTemplateDayExercise(templateId, dayId, exerciseId),
      data: {'exercise_order': ?exerciseOrder, 'notes': ?notes},
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutTemplateModel> deleteTemplateExercise(
    String templateId,
    String dayId,
    String exerciseId,
  ) async {
    final response = await _dio.delete(
      ApiEndpoints.workoutTemplateDayExercise(templateId, dayId, exerciseId),
    );
    return WorkoutTemplateModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> assignTemplate(
    String templateId, {
    required String coachClientId,
    String? title,
    String? description,
  }) async {
    // Never send start_date — backend generates Cairo today.
    final response = await _dio.post(
      ApiEndpoints.assignWorkoutTemplateV1(templateId),
      data: {
        'coach_client_id': coachClientId,
        'title': ?title,
        'description': ?description,
      },
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlansPage> getPlans({
    required String clientId,
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.workoutPlans,
      queryParameters: {
        'client_id': clientId,
        'is_active': ?isActive,
        'page': page,
        'pageSize': pageSize.clamp(1, 100),
      },
    );
    final data = _dataMap(response.data);
    final items = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(WorkoutPlanSummaryModel.fromJson)
        .toList();
    final pagination = ApiPagination.fromJson(
      data['pagination'] as Map<String, dynamic>? ?? {},
    );
    return (plans: items, pagination: pagination);
  }

  @override
  Future<WorkoutPlanModel> getPlan(String planId) async {
    final response = await _dio.get(ApiEndpoints.workoutPlan(planId));
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> updatePlan(
    String planId, {
    String? title,
    String? description,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workoutPlan(planId),
      data: {'title': ?title, 'description': ?description},
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<void> deletePlan(String planId) async {
    await _dio.delete(ApiEndpoints.workoutPlan(planId));
  }

  @override
  Future<WorkoutPlanModel> createPlanDay(
    String planId, {
    required String title,
    String? note,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workoutPlanDays(planId),
      data: {'title': title, 'note': ?note},
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> updatePlanDay(
    String planId,
    String dayId, {
    String? title,
    int? dayNumber,
    bool? isRest,
    String? note,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workoutPlanDay(planId, dayId),
      data: {
        'title': ?title,
        'day_number': ?dayNumber,
        'is_rest': ?isRest,
        'note': ?note,
      },
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> deletePlanDay(String planId, String dayId) async {
    final response = await _dio.delete(
      ApiEndpoints.workoutPlanDay(planId, dayId),
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> reorderPlanDays(
    String planId,
    List<String> dayIds,
  ) async {
    final response = await _dio.put(
      ApiEndpoints.workoutPlanDaysReorder(planId),
      data: {
        'day_ids': dayIds,
      },
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> addPlanExercise(
    String planId,
    String dayId, {
    required String exerciseId,
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.workoutPlanDayExercises(planId, dayId),
      data: {
        'exercise_id': exerciseId,
        'order_number': ?orderNumber,
        'sets': ?sets,
        'reps': ?reps,
        'rest_time': ?restTime,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> updatePlanExercise(
    String planId,
    String dayId,
    String exerciseId, {
    int? orderNumber,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.workoutPlanDayExercise(planId, dayId, exerciseId),
      data: {
        'order_number': ?orderNumber,
        'sets': ?sets,
        'reps': ?reps,
        'rest_time': ?restTime,
        'notes': ?notes,
      },
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel> deletePlanExercise(
    String planId,
    String dayId,
    String exerciseId,
  ) async {
    final response = await _dio.delete(
      ApiEndpoints.workoutPlanDayExercise(planId, dayId, exerciseId),
    );
    return WorkoutPlanModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<TodayWorkoutModel?> getTodayWorkout() async {
    final response = await _dio.get(ApiEndpoints.workoutToday);
    return TodayWorkoutModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<ExerciseCompletionModel> completeExercise(String logId) async {
    final response = await _dio.post(
      ApiEndpoints.workoutExerciseComplete(logId),
    );
    return ExerciseCompletionModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<ExerciseCompletionModel> uncompleteExercise(String logId) async {
    final response = await _dio.post(
      ApiEndpoints.workoutExerciseUncomplete(logId),
    );
    return ExerciseCompletionModel.fromResponse(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<WorkoutPlanModel?> getMyActivePlan() async {
    final response = await _dio.get(ApiEndpoints.workoutMyPlans);
    final body = response.data as Map<String, dynamic>? ?? {};
    final data = body['data'];
    final Map<String, dynamic> root =
        data is Map<String, dynamic> ? data : body;
    final plan = root['plan'];
    if (plan == null) return null;
    if (plan is! Map<String, dynamic>) return null;
    return WorkoutPlanModel.fromJson(plan);
  }

  @override
  Future<WorkoutPlanModel> getMyPlanDetails(String planId) async {
    final response = await _dio.get(ApiEndpoints.workoutMyPlan(planId));
    final body = response.data as Map<String, dynamic>? ?? {};
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final plan = data['plan'];
      if (plan is Map<String, dynamic>) {
        return WorkoutPlanModel.fromJson(plan);
      }
      return WorkoutPlanModel.fromJson(data);
    }
    return WorkoutPlanModel.fromJson(body);
  }

  @override
  Future<WorkoutHistoryModel> getHistory() async {
    // No params — backend derives range from plan start_date to today.
    final response = await _dio.get(ApiEndpoints.workoutHistory);
    return WorkoutHistoryModel.fromJson(
      response.data as Map<String, dynamic>? ?? {},
    );
  }
}
