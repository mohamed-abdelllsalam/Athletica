import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/features/workout/domain/entities/workout_plan.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';

sealed class WorkoutPlansState {
  const WorkoutPlansState();
}

final class WorkoutPlansInitial extends WorkoutPlansState {
  const WorkoutPlansInitial();
}

final class WorkoutPlansLoading extends WorkoutPlansState {
  const WorkoutPlansLoading();
}

final class WorkoutPlansLoaded extends WorkoutPlansState {
  const WorkoutPlansLoaded(
    this.items,
    this.pagination, {
    this.connectionError = false,
  });

  final List<WorkoutPlanSummary> items;
  final ApiPagination pagination;
  final bool connectionError;
}

final class WorkoutPlansError extends WorkoutPlansState {
  const WorkoutPlansError(this.message, {this.connectionError = false});
  final String message;
  final bool connectionError;
}

sealed class WorkoutPlanDetailState {
  const WorkoutPlanDetailState();
}

final class WorkoutPlanDetailInitial extends WorkoutPlanDetailState {
  const WorkoutPlanDetailInitial();
}

final class WorkoutPlanDetailLoading extends WorkoutPlanDetailState {
  const WorkoutPlanDetailLoading();
}

final class WorkoutPlanDetailLoaded extends WorkoutPlanDetailState {
  const WorkoutPlanDetailLoaded(
    this.plan, {
    this.mutating = false,
    this.connectionError = false,
  });

  final WorkoutPlanEntry plan;
  final bool mutating;
  final bool connectionError;
}

final class WorkoutPlanDetailError extends WorkoutPlanDetailState {
  const WorkoutPlanDetailError(this.message, {this.connectionError = false});
  final String message;
  final bool connectionError;
}
