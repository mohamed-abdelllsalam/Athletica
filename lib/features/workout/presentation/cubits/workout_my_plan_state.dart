import 'package:athletica/features/workout/domain/entities/workout_history.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';

sealed class WorkoutMyPlanState {
  const WorkoutMyPlanState();
}

final class WorkoutMyPlanInitial extends WorkoutMyPlanState {
  const WorkoutMyPlanInitial();
}

final class WorkoutMyPlanLoading extends WorkoutMyPlanState {
  const WorkoutMyPlanLoading();
}

/// Null [plan] means `{plan: null}` — show the empty state.
final class WorkoutMyPlanLoaded extends WorkoutMyPlanState {
  const WorkoutMyPlanLoaded(this.plan);
  final WorkoutPlanEntry? plan;
}

final class WorkoutMyPlanDetailLoaded extends WorkoutMyPlanState {
  const WorkoutMyPlanDetailLoaded(this.plan);
  final WorkoutPlanEntry plan;
}

final class WorkoutMyPlanError extends WorkoutMyPlanState {
  const WorkoutMyPlanError(this.message);
  final String message;
}

sealed class WorkoutHistoryState {
  const WorkoutHistoryState();
}

final class WorkoutHistoryInitial extends WorkoutHistoryState {
  const WorkoutHistoryInitial();
}

final class WorkoutHistoryLoading extends WorkoutHistoryState {
  const WorkoutHistoryLoading();
}

final class WorkoutHistoryLoaded extends WorkoutHistoryState {
  const WorkoutHistoryLoaded(this.days);
  final List<WorkoutHistoryDay> days;
}

final class WorkoutHistoryError extends WorkoutHistoryState {
  const WorkoutHistoryError(this.message);
  final String message;
}
