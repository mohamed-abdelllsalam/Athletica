import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';

/// Parses `GET /client/coach`:
/// `{ "coach": { "id", "user": { "username", "email" }, "bio",
///    "specialization" }, "assigned_at": "..." }`
class AssignedCoachModel {
  const AssignedCoachModel({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.specialization,
    this.assignedAt,
  });

  final String id;
  final String username;
  final String email;
  final String bio;
  final String specialization;
  final DateTime? assignedAt;

  factory AssignedCoachModel.fromJson(Map<String, dynamic> json) {
    final coach = json['coach'] as Map<String, dynamic>? ?? {};
    final user = coach['user'] as Map<String, dynamic>? ?? {};
    return AssignedCoachModel(
      id: coach['id'] as String? ?? '',
      username: user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      bio: coach['bio'] as String? ?? '',
      specialization: coach['specialization'] as String? ?? '',
      assignedAt: DateTime.tryParse(json['assigned_at'] as String? ?? ''),
    );
  }

  AssignedCoach toEntity() => AssignedCoach(
        id: id,
        username: username,
        email: email,
        bio: bio,
        specialization: specialization,
        assignedAt: assignedAt,
      );
}
