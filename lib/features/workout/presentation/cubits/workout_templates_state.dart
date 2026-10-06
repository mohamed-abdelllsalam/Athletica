import 'package:athletica/core/network/api_pagination.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';

sealed class WorkoutTemplatesState {
  const WorkoutTemplatesState();
}

final class WorkoutTemplatesInitial extends WorkoutTemplatesState {
  const WorkoutTemplatesInitial();
}

final class WorkoutTemplatesLoading extends WorkoutTemplatesState {
  const WorkoutTemplatesLoading();
}

final class WorkoutTemplatesLoaded extends WorkoutTemplatesState {
  const WorkoutTemplatesLoaded(
    this.items,
    this.pagination, {
    this.mutating = false,
    this.mutationError,
    this.connectionError = false,
  });

  final List<WorkoutTemplateEntry> items;
  final ApiPagination pagination;

  /// True while a create/delete is in flight; [mutationError] carries a
  /// failed mutation message while keeping the loaded list visible.
  final bool mutating;
  final String? mutationError;
  final bool connectionError;
}

final class WorkoutTemplatesError extends WorkoutTemplatesState {
  const WorkoutTemplatesError(this.message, {this.connectionError = false});
  final String message;
  final bool connectionError;
}
