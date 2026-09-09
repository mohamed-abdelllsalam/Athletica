import 'package:athletica/features/workout/domain/entities/workout_template.dart';

sealed class WorkoutTemplateDetailState {
  const WorkoutTemplateDetailState();
}

final class WorkoutTemplateDetailInitial extends WorkoutTemplateDetailState {
  const WorkoutTemplateDetailInitial();
}

final class WorkoutTemplateDetailLoading extends WorkoutTemplateDetailState {
  const WorkoutTemplateDetailLoading();
}

final class WorkoutTemplateDetailLoaded extends WorkoutTemplateDetailState {
  const WorkoutTemplateDetailLoaded(this.template, {this.mutating = false});

  final WorkoutTemplateEntry template;
  final bool mutating;
}

final class WorkoutTemplateDetailError extends WorkoutTemplateDetailState {
  const WorkoutTemplateDetailError(this.message);
  final String message;
}
