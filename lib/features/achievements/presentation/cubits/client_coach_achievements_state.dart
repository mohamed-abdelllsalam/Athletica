import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';

sealed class ClientCoachAchievementsState {
  const ClientCoachAchievementsState();
}

final class ClientCoachAchievementsInitial
    extends ClientCoachAchievementsState {
  const ClientCoachAchievementsInitial();
}

final class ClientCoachAchievementsLoading
    extends ClientCoachAchievementsState {
  const ClientCoachAchievementsLoading();
}

final class ClientCoachAchievementsLoaded extends ClientCoachAchievementsState {
  const ClientCoachAchievementsLoaded(
    this.achievements, {
    this.connectionError = false,
  });

  final List<CoachAchievement> achievements;
  final bool connectionError;
}

final class ClientCoachAchievementsError extends ClientCoachAchievementsState {
  const ClientCoachAchievementsError(
    this.message, {
    this.connectionError = false,
  });

  final String message;
  final bool connectionError;
}
