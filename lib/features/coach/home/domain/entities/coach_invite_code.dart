/// Active coach invite from `POST /coach/invite`.
///
/// [code] is the short 6-character invite code (e.g. `M7MUMQ`) the client
/// can type manually. [token] is the same value embedded in [inviteUrl].
class CoachInviteCode {
  const CoachInviteCode({
    required this.code,
    required this.token,
    required this.inviteUrl,
    this.expiresAt,
  });

  final String code;
  final String token;
  final String inviteUrl;
  final DateTime? expiresAt;
}
