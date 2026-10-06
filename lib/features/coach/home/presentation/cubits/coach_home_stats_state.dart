import 'package:athletica/features/coach/home/domain/entities/coach_home_stats.dart';

sealed class CoachHomeStatsState {}

final class CoachHomeStatsInitial extends CoachHomeStatsState {}

final class CoachHomeStatsLoading extends CoachHomeStatsState {}

final class CoachHomeStatsLoaded extends CoachHomeStatsState {
  CoachHomeStatsLoaded(this.stats, {this.isConnectionError = false});
  final bool isConnectionError;
  final CoachHomeStats stats;
}

final class CoachHomeStatsError extends CoachHomeStatsState {
  CoachHomeStatsError(this.message, {this.isConnectionError = false});
  final bool isConnectionError;
  final String message;
}
