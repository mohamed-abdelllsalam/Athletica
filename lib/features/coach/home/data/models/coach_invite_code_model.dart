import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';

/// Parses `POST /coach/invite`:
/// `{ "code": "M7MUMQ", "token": "M7MUMQ", "invite_url": "...", "expires_at": "..." }`
class CoachInviteCodeModel {
  const CoachInviteCodeModel({
    required this.code,
    required this.token,
    required this.inviteUrl,
    this.expiresAt,
  });

  final String code;
  final String token;
  final String inviteUrl;
  final DateTime? expiresAt;

  factory CoachInviteCodeModel.fromJson(Map<String, dynamic> json) {
    return CoachInviteCodeModel(
      code: json['code'] as String? ?? '',
      token: json['token'] as String? ?? '',
      inviteUrl:
          json['invite_url'] as String? ?? json['inviteLink'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
    );
  }

  CoachInviteCode toEntity() => CoachInviteCode(
        code: code,
        token: token,
        inviteUrl: inviteUrl,
        expiresAt: expiresAt,
      );
}
