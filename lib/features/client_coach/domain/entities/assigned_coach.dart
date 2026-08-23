/// The client's assigned coach from `GET /client/coach`.
class AssignedCoach {
  const AssignedCoach({
    required this.id,
    required this.username,
    required this.email,
    this.bio = '',
    this.specialization = '',
    this.assignedAt,
  });

  final String id;
  final String username;
  final String email;
  final String bio;
  final String specialization;
  final DateTime? assignedAt;
}
