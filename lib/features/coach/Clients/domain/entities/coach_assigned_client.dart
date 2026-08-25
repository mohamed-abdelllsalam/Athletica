/// A client assigned to the coach, from `GET /coach/clients`.
///
/// [relationId] is the `coach_clients.id` — the value used to remove the
/// client (`DELETE /coach/clients/:id`) and as `coach_client_id` when
/// assigning a nutrition plan.
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
