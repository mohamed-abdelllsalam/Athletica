import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/streak/domain/entities/streak_data.dart';

abstract class StreakRepository {
  Future<ApiResult<StreakData>> getClientStreak();
  Future<ApiResult<StreakData>> getCoachClientStreak(String coachClientId);
}
