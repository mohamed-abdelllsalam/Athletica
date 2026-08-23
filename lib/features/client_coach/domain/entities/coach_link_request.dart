/// Result of `POST /coach-requests` (client submitting an invite token).
class CoachLinkRequest {
  const CoachLinkRequest({required this.id, required this.status});

  final String id;
  final String status;
}
