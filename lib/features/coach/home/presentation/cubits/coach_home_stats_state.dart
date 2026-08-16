import 'package:athletica/features/coach/home/domain/entities/coach_home_stats.dart';

sealed class CoachHomeStatsState {}

final class CoachHomeStatsInitial extends CoachHomeStatsState {}

final class CoachHomeStatsLoading extends CoachHomeStatsState {}

final class CoachHomeStatsLoaded extends CoachHomeStatsState {
  CoachHomeStatsLoaded(this.stats);
  final CoachHomeStats stats;
}

final class CoachHomeStatsError extends CoachHomeStatsState {
  CoachHomeStatsError(this.message);
  final String message;
}
