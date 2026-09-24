/// The client's assigned coach from `GET /client/coach`.
class AssignedCoach {
  const AssignedCoach({
    required this.id,
    required this.username,
    required this.email,
    required this.assignmentId,
    this.bio = '',
    this.specialization = '',
    this.assignedAt,
    this.imageUrl,
  });

  final String id;
  final String username;
  final String email;
  final String assignmentId;
  final String bio;
  final String specialization;
  final DateTime? assignedAt;

  /// Best-effort profile photo; null when the API omits it.
  final String? imageUrl;

  bool get hasPhoto {
    final url = imageUrl?.trim();
    return url != null && url.isNotEmpty && url.toLowerCase() != 'null';
  }
}
