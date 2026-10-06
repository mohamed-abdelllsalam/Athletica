import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';

sealed class CoachAchievementsState {
  const CoachAchievementsState();
}

final class CoachAchievementsInitial extends CoachAchievementsState {
  const CoachAchievementsInitial();
}

final class CoachAchievementsLoading extends CoachAchievementsState {
  const CoachAchievementsLoading();
}

final class CoachAchievementsLoaded extends CoachAchievementsState {
  const CoachAchievementsLoaded(this.achievements);

  final List<CoachAchievement> achievements;
}

final class CoachAchievementsDeleting extends CoachAchievementsState {
  const CoachAchievementsDeleting(this.achievements, this.achievementId);

  final List<CoachAchievement> achievements;
  final String achievementId;
}

final class CoachAchievementsDeleteSuccess extends CoachAchievementsState {
  const CoachAchievementsDeleteSuccess(this.achievements, this.title);

  final List<CoachAchievement> achievements;
  final String title;
}

final class CoachAchievementsError extends CoachAchievementsState {
  const CoachAchievementsError(
    this.message, {
    this.previous,
    this.connectionError = false,
  });

  final String message;
  final List<CoachAchievement>? previous;
  final bool connectionError;
}
