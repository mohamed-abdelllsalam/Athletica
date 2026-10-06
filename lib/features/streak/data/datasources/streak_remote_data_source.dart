import 'package:athletica/core/errors/api_error_mapper.dart';
import 'package:athletica/core/errors/failures.dart';
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
    AppFailure? workoutFailure;
    AppFailure? nutritionFailure;

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
    } on DioException catch (error) {
      // No active plan (e.g. after leaving the coach) means there is simply
      // no streak yet — kept empty so the UI shows "No streak activity yet"
      // instead of a 404 error.
      if (!_isEmptyStreak(error)) {
        workoutFailure = mapDioException(error);
        workoutError = workoutFailure.message;
      }
    } catch (_) {
      workoutError = 'Unable to load workout streak.';
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
    } on DioException catch (error) {
      if (!_isEmptyStreak(error)) {
        nutritionFailure = mapDioException(error);
        nutritionError = nutritionFailure.message;
      }
    } catch (_) {
      nutritionError = 'Unable to load nutrition streak.';
    }

    if (workoutSummary == null &&
        nutritionSummary == null &&
        (workoutFailure != null ||
            nutritionFailure != null ||
            workoutError != null ||
            nutritionError != null) &&
        workoutFailure is! NetworkFailure &&
        nutritionFailure is! NetworkFailure) {
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
      workoutFailure: workoutFailure,
      nutritionFailure: nutritionFailure,
    );
  }

  /// 404-style "no data" responses (no active plan, no coach assigned) mean
  /// an empty streak, not a failure — mirroring the nutrition/assigned
  /// data sources. Accepts both snake_case keys and human-readable values.
  static bool _isEmptyStreak(DioException error) {
    final data = error.response?.data;
    final key = data is Map<String, dynamic> ? data['error'] : null;
    final normalized = key is String
        ? key.toLowerCase().trim().replaceAll(' ', '_')
        : null;
    return normalized == 'no_active_plan_found' ||
        normalized == 'no_coach_assigned';
  }
}

class StreakFetchException implements Exception {
  const StreakFetchException(this.message);
  final String message;
}
