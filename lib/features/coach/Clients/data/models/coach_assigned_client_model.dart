import 'package:athletica/core/utils/goal_format.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';

/// Parses a `GET /coach/clients` entry:
/// `{ id, client: { id, user: { username, email, name }, profile_image, gender, birth_date, height, weight, goal }, assigned_at }`
///
/// NOTE: for removal, the backend expects the nested `client.id`, not the
/// entry-level `id`.
class CoachAssignedClientModel {
  const CoachAssignedClientModel({
    required this.relationId,
    required this.clientId,
    required this.name,
    required this.email,
    required this.goal,
    this.profileImage,
    this.gender,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.assignedAt,
  });

  final String relationId;
  final String clientId;
  final String name;
  final String email;
  final String goal;
  final String? profileImage;
  final String? gender;
  final DateTime? birthDate;
  final num? heightCm;
  final num? weightKg;
  final DateTime? assignedAt;

  factory CoachAssignedClientModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>? ?? {};
    final user = client['user'] as Map<String, dynamic>? ?? {};
    return CoachAssignedClientModel(
      relationId: json['id'] as String? ?? '',
      clientId: client['id'] as String? ?? '',
      name: user['name'] as String? ?? user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      goal: normalizeGoalValue(client['goal'] as String? ?? ''),
      profileImage: client['profile_image'] as String?,
      gender: client['gender'] as String?,
      birthDate: DateTime.tryParse(client['birth_date'] as String? ?? ''),
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
        profileImage: profileImage,
        gender: gender,
        birthDate: birthDate,
        heightCm: heightCm,
        weightKg: weightKg,
        assignedAt: assignedAt,
      );
}
