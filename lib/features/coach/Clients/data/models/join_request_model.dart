import 'package:athletica/core/utils/goal_format.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';

/// Parses a `GET /coach/requests` entry:
/// `{ id, client: { id, user: { username, email }, goal }, status,
///    created_at, rejected_at }`
class JoinRequestModel {
  const JoinRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String goal;
  final String status;
  final DateTime? createdAt;

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>? ?? {};
    final user = client['user'] as Map<String, dynamic>? ?? {};
    return JoinRequestModel(
      id: json['id'] as String? ?? '',
      name: user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      goal: normalizeGoalValue(client['goal'] as String? ?? ''),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  JoinRequest toEntity() => JoinRequest(
        id: id,
        name: name,
        email: email,
        goal: goal,
        status: status,
        createdAt: createdAt,
      );
}
