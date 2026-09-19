/// An entry from `GET /coach/clients`.
///
/// [relationId] is the `coach_clients.id` — the value required as
/// `coach_client_id` when assigning a nutrition plan. It is NOT the
/// client user/profile id.
class AssignedClient {
  const AssignedClient({
    required this.relationId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.goal,
  });

  final String relationId;

  /// `client_profiles.id` of the assigned client. Used to resolve the
  /// intended roster entry when the caller only knows the profile id.
  final String clientId;
  final String name;
  final String email;
  final String goal;
}
