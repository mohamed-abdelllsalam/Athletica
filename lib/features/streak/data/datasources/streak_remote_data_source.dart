import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/features/streak/data/models/streak_models.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';
import 'package:dio/dio.dart';

abstract class StreakRemoteDataSource {
  Future<StreakData> getClientStreak();
  Future<StreakData> getCoachClientStreak(String coachClientId);
}

class StreakRemoteDataSourceImpl implements StreakRemoteDataSource {
  const StreakRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<StreakData> getClientStreak() async => _fetch(
    workoutPath: ApiEndpoints.workoutStreak,
    nutritionPath: ApiEndpoints.nutritionStreak,
  );

  @override
  Future<StreakData> getCoachClientStreak(String coachClientId) async => _fetch(
    workoutPath: ApiEndpoints.coachWorkoutStreak(coachClientId),
    nutritionPath: ApiEndpoints.coachNutritionStreak(coachClientId),
  );

  Future<StreakData> _fetch({
    required String workoutPath,
    required String nutritionPath,
  }) async {
    StreakSummaryModel? workoutSummary;
    List<WorkoutStreakDayModel> workoutDays = [];
    StreakSummaryModel? nutritionSummary;
    List<NutritionStreakDayModel> nutritionDays = [];
    String? workoutError;
    String? nutritionError;

    try {
      final response = await _dio.get(workoutPath);
      final envelope = response.data as Map<String, dynamic>;
      final workout = envelope['data'] as Map<String, dynamic>;
      final parsedSummary = StreakSummaryModel.fromJson(workout);
      workoutDays = (workout['days'] as List<dynamic>)
          .map(
            (day) =>
                WorkoutStreakDayModel.fromJson(day as Map<String, dynamic>),
          )
          .toList();
      workoutSummary = parsedSummary;
    } catch (error) {
      workoutError = _errorMessage(error, 'Unable to load workout streak.');
    }

    try {
      final response = await _dio.get(nutritionPath);
      final nutrition = response.data as Map<String, dynamic>;
      final parsedSummary = StreakSummaryModel.fromJson(nutrition);
      nutritionDays = (nutrition['days'] as List<dynamic>)
          .map(
            (day) =>
                NutritionStreakDayModel.fromJson(day as Map<String, dynamic>),
          )
          .toList();
      nutritionSummary = parsedSummary;
    } catch (error) {
      nutritionError = _errorMessage(error, 'Unable to load nutrition streak.');
    }

    if (workoutSummary == null && nutritionSummary == null) {
      throw StreakFetchException(
        workoutError ?? nutritionError ?? 'Unable to load streaks.',
      );
    }
    return StreakData(
      workoutSummary: workoutSummary,
      workoutDays: workoutDays,
      nutritionSummary: nutritionSummary,
      nutritionDays: nutritionDays,
      workoutError: workoutError,
      nutritionError: nutritionError,
    );
  }

  String _errorMessage(Object error, String fallback) =>
      error is DioException ? error.message ?? fallback : fallback;
}

class StreakFetchException implements Exception {
  const StreakFetchException(this.message);
  final String message;
}
