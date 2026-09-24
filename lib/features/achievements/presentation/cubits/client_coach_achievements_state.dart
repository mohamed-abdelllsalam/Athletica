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
  const ClientCoachAchievementsLoaded(this.achievements);

  final List<CoachAchievement> achievements;
}

final class ClientCoachAchievementsError extends ClientCoachAchievementsState {
  const ClientCoachAchievementsError(this.message);

  final String message;
}
