import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';

/// Parses a `GET /coach/clients` entry:
/// `{ id, client: { id, user: { username, email }, goal, height, weight }, assigned_at }`
class CoachAssignedClientModel {
  const CoachAssignedClientModel({
    required this.relationId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.goal,
    required this.heightCm,
    required this.weightKg,
    required this.assignedAt,
  });

  final String relationId;
  final String clientId;
  final String name;
  final String email;
  final String goal;
  final num? heightCm;
  final num? weightKg;
  final DateTime? assignedAt;

  factory CoachAssignedClientModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>? ?? {};
    final user = client['user'] as Map<String, dynamic>? ?? {};
    return CoachAssignedClientModel(
      relationId: json['id'] as String? ?? '',
      clientId: client['id'] as String? ?? '',
      name: user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      goal: client['goal'] as String? ?? '',
      heightCm: client['height'] as num?,
      weightKg: client['weight'] as num?,
      assignedAt: DateTime.tryParse(json['assigned_at'] as String? ?? ''),
    );
  }

  CoachAssignedClient toEntity() => CoachAssignedClient(
        relationId: relationId,
        clientId: clientId,
        name: name,
        email: email,
        goal: goal,
        heightCm: heightCm,
        weightKg: weightKg,
        assignedAt: assignedAt,
      );
}
