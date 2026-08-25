/// A client assigned to the coach, from `GET /coach/clients`.
///
/// [relationId] is the entry-level `id`. For removal the backend expects
/// [clientId] (verified against the live backend); [relationId] is kept as
/// the list key and for assigning nutrition plans.
class CoachAssignedClient {
  const CoachAssignedClient({
    required this.relationId,
    required this.clientId,
    required this.name,
    required this.email,
    this.goal = '',
    this.heightCm,
    this.weightKg,
    this.assignedAt,
  });

  final String relationId;
  final String clientId;
  final String name;
  final String email;
  final String goal;
  final num? heightCm;
  final num? weightKg;
  final DateTime? assignedAt;
}
