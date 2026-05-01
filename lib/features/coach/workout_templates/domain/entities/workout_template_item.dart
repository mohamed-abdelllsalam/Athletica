class WorkoutTemplateItem {
  const WorkoutTemplateItem({
    required this.id,
    required this.workoutTemplateDayId,
    required this.exerciseId,
    required this.order,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
    this.tempo,
    this.rir,
    this.rpe,
  });

  final String id;
  final String workoutTemplateDayId;
  final String exerciseId;
  final int order;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;
  final String? tempo;
  final int? rir;
  final int? rpe;
}
