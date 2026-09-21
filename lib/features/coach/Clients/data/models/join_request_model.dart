import 'package:athletica/core/utils/goal_format.dart';
import 'package:athletica/features/coach/clients/domain/entities/join_request.dart';

/// Parses a `GET /coach/requests` entry:
/// `{ id, client: { id, user: { username, email }, profile_image, goal },
///    status, created_at, rejected_at }`
class JoinRequestModel {
  const JoinRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    required this.status,
    this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String email;
  final String goal;
  final String status;
  final DateTime? createdAt;

  /// Requester's network photo; null when the API omits it.
  final String? imageUrl;

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>? ?? {};
    final user = client['user'] as Map<String, dynamic>? ?? {};
    return JoinRequestModel(
      // Ids may arrive as ints on newer backends; never cast.
      id: json['id']?.toString() ?? '',
      name: user['username']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      goal: normalizeGoalValue(client['goal']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      imageUrl: _parseImageUrl(client),
    );
  }

  static const _imageKeys = [
    'profile_image',
    'profile_image_url',
    'image',
    'image_url',
    'avatar',
    'photo',
  ];

  static String? _parseImageUrl(Map<String, dynamic> client) {
    for (final key in _imageKeys) {
      final value = client[key];
      if (value is! String) continue;
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') continue;
      return trimmed;
    }
    return null;
  }

  JoinRequest toEntity() => JoinRequest(
        id: id,
        name: name,
        email: email,
        goal: goal,
        status: status,
        createdAt: createdAt,
        imageUrl: imageUrl,
      );
}
