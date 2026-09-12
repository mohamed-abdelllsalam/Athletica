/// Selection return type for the exercise search picker. Instances are
/// mapped from `GET /workout/exercises` results (real API ids) — no
/// hardcoded catalog remains here.
class PlanExercise {
  const PlanExercise({
    required this.id,
    required this.name,
    this.thumbnailUrl = '',
    this.videoUrlMale = '',
    this.videoUrlFemale = '',
  });

  final String id;
  final String name;

  /// Backend demo media for playback/thumbnails in day views.
  final String thumbnailUrl;
  final String videoUrlMale;
  final String videoUrlFemale;
}
