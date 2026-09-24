import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/achievements/domain/repositories/achievements_repository.dart';

class GetCoachAchievementsUseCase {
  const GetCoachAchievementsUseCase(this._repository);

  final AchievementsRepository _repository;

  Future<ApiResult<List<CoachAchievement>>> call() =>
      _repository.getCoachAchievements();
}
