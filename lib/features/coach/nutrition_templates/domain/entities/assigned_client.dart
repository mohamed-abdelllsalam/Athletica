/// An entry from `GET /coach/clients`.
///
/// [relationId] is the `coach_clients.id` — the value required as
/// `coach_client_id` when assigning a nutrition plan. It is NOT the
/// client user/profile id.
class AssignedClient {
  const AssignedClient({
    required this.relationId,
    required this.name,
    required this.email,
    required this.goal,
  });

  final String relationId;
  final String name;
  final String email;
  final String goal;
}
