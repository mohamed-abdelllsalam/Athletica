import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';

/// Parses `POST /coach/invite`:
/// `{ "token": "...", "invite_url": "...", "expires_at": "..." }`
class CoachInviteCodeModel {
  const CoachInviteCodeModel({
    required this.token,
    required this.inviteUrl,
    this.expiresAt,
  });

  final String token;
  final String inviteUrl;
  final DateTime? expiresAt;

  factory CoachInviteCodeModel.fromJson(Map<String, dynamic> json) {
    return CoachInviteCodeModel(
      token: json['token'] as String? ?? '',
      inviteUrl:
          json['invite_url'] as String? ?? json['inviteLink'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
    );
  }

  CoachInviteCode toEntity() => CoachInviteCode(
        token: token,
        inviteUrl: inviteUrl,
        expiresAt: expiresAt,
      );
}
