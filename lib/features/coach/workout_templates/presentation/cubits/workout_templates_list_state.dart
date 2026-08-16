import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';

sealed class WorkoutTemplatesListState {}

final class WorkoutTemplatesListInitial extends WorkoutTemplatesListState {}

final class WorkoutTemplatesListLoading extends WorkoutTemplatesListState {}

final class WorkoutTemplatesListLoaded extends WorkoutTemplatesListState {
  WorkoutTemplatesListLoaded(this.programs);
  final List<WorkoutProgram> programs;
}

final class WorkoutTemplatesListError extends WorkoutTemplatesListState {
  WorkoutTemplatesListError(this.message);
  final String message;
}
