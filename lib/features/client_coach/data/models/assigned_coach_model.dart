import 'package:athletica/features/client_coach/domain/entities/assigned_coach.dart';

/// Parses `GET /client/coach`.
///
/// Documented shape (DOC_2.md):
/// `{ "coach": { "id", "user": { "username", "email" }, "bio",
///    "specialization", "profile_image" }, "assigned_at": "..." }`
///
/// The real backend also returns the `GET /profile` shape in places
/// (`{ "user": {...}, "profile": { "profile_image", ... } }`) and may wrap
/// the payload in `data`, so [imageUrl] is parsed best-effort from every
/// known location; null when the API omits it.
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
    // Unwrap `{ "data": {...} }` when the backend envelopes the payload.
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final coach = root['coach'] is Map<String, dynamic>
        ? root['coach'] as Map<String, dynamic>
        : root;
    final user = coach['user'] is Map<String, dynamic>
        ? coach['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    // Mirrors GET /profile: `{ "user": {...}, "profile": {...} }`.
    final profile = coach['profile'] is Map<String, dynamic>
        ? coach['profile'] as Map<String, dynamic>
        : <String, dynamic>{};
    return AssignedCoachModel(
      id: (coach['id'] ?? root['id'])?.toString() ?? '',
      username: _stringFrom([user, coach, root], const [
            'username',
            'name',
          ]) ??
          '',
      email:
          _stringFrom([user, coach, root], const ['email']) ?? '',
      bio: _stringFrom([profile, coach, root], const ['bio']) ?? '',
      specialization:
          _stringFrom([profile, coach, root], const ['specialization']) ?? '',
      imageUrl: _parseImageUrl(root, coach, profile, user),
      assignedAt: DateTime.tryParse(
        (root['assigned_at'] ?? json['assigned_at'])?.toString() ?? '',
      ),
    );
  }

  static const List<String> _imageKeys = [
    'profile_image',
    'profileImage',
    'profile_image_url',
    'profileImageUrl',
    'image',
    'imageUrl',
    'image_url',
    'avatar',
    'avatar_url',
    'photo',
    'photo_url',
    'picture',
    'profile_picture',
  ];

  static String? _stringFrom(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    return null;
  }

  static String? _parseImageUrl(
    Map<String, dynamic> root,
    Map<String, dynamic> coach,
    Map<String, dynamic> profile,
    Map<String, dynamic> user,
  ) {
    // Order matters: most-specific first (nested profile/user), then the
    // flat coach object from DOC_2.md, then the top level.
    for (final source in [profile, user, coach, root]) {
      for (final key in _imageKeys) {
        final candidate = _asUrlString(source[key]);
        if (candidate != null) return candidate;
      }
      // Some backends nest the file as `{ "profile_image": { "url": "..." } }`.
      for (final key in _imageKeys) {
        final value = source[key];
        if (value is Map<String, dynamic>) {
          for (final nestedKey in const ['url', 'secure_url', 'src', 'path']) {
            final candidate = _asUrlString(value[nestedKey]);
            if (candidate != null) return candidate;
          }
        }
      }
    }
    return null;
  }

  /// Trims whitespace and drops empty / literal `"null"` values so
  /// [AssignedCoach.hasPhoto] stays reliable.
  static String? _asUrlString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
    return trimmed;
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
