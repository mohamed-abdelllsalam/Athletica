import 'dart:io';

import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';

abstract class AchievementsRepository {
  Future<ApiResult<List<CoachAchievement>>> getCoachAchievements();

  Future<ApiResult<CoachAchievement>> uploadCoachAchievement({
    required String title,
    required File file,
  });

  Future<ApiResult<void>> deleteCoachAchievement(String id);

  Future<ApiResult<List<CoachAchievement>>> getAssignedCoachAchievements();
}
