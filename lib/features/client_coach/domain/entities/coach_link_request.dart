/// Result of `POST /coach-requests` (client submitting an invite token).
///
/// [coachName] is best-effort (empty when the API does not include it).
class CoachLinkRequest {
  const CoachLinkRequest({
    required this.id,
    required this.status,
    this.coachName = '',
  });

  final String id;
  final String status;
  final String coachName;

  bool get hasCoachName => coachName.isNotEmpty;
}
