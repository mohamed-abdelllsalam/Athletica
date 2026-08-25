import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';

/// Parses `GET /client/coach`:
/// `{ "coach": { "id", "user": { "username", "email" }, "bio",
///    "specialization" }, "assigned_at": "..." }`
///
/// [imageUrl] is best-effort parsed from common photo fields; null when the
/// API omits them.
class AssignedCoachModel {
  const AssignedCoachModel({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.specialization,
    required this.imageUrl,
    this.assignedAt,
  });

  final String id;
  final String username;
  final String email;
  final String bio;
  final String specialization;
  final String? imageUrl;
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
      imageUrl: _parseImageUrl(coach, user),
      assignedAt: DateTime.tryParse(json['assigned_at'] as String? ?? ''),
    );
  }

  static const List<String> _imageKeys = [
    'image',
    'imageUrl',
    'avatar',
    'photo',
    'profile_image',
    'profileImage',
  ];

  static String? _parseImageUrl(
    Map<String, dynamic> coach,
    Map<String, dynamic> user,
  ) {
    for (final source in [user, coach]) {
      for (final key in _imageKeys) {
        final value = source[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  AssignedCoach toEntity() => AssignedCoach(
        id: id,
        username: username,
        email: email,
        bio: bio,
        specialization: specialization,
        assignedAt: assignedAt,
        imageUrl: imageUrl,
      );
}
