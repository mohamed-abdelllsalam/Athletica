class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.trainerId,
    required this.title,
    required this.level,
    required this.createdAt,
  });

  final String id;
  final String trainerId;
  final String title;
  final String level;
  final DateTime createdAt;
}
