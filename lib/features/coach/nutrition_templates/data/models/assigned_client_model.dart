import 'package:athletica/core/utils/goal_format.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';

/// Parses `GET /coach/clients` entries:
/// { id, client: { id, user: { username, email }, goal, ... }, assigned_at }
class AssignedClientModel {
  const AssignedClientModel({
    required this.relationId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.goal,
    this.profileImage,
  });

  final String relationId;
  final String clientId;
  final String name;
  final String email;
  final String goal;
  final String? profileImage;

  factory AssignedClientModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>? ?? {};
    final user = client['user'] as Map<String, dynamic>? ?? {};
    return AssignedClientModel(
      relationId: (json['id'] as String?) ?? '',
      clientId: (client['id'] as String?) ?? '',
      name: (user['username'] as String?) ?? '',
      email: (user['email'] as String?) ?? '',
      goal: normalizeGoalValue((client['goal'] as String?) ?? ''),
      profileImage: client['profile_image'] as String?,
    );
  }

  AssignedClient toEntity() => AssignedClient(
        relationId: relationId,
        clientId: clientId,
        name: name,
        email: email,
        goal: goal,
        profileImage: profileImage,
      );
}
