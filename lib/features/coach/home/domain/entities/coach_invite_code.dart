/// Active coach invite link from `POST /coach/invite`.
class CoachInviteCode {
  const CoachInviteCode({
    required this.token,
    required this.inviteUrl,
    this.expiresAt,
  });

  final String token;
  final String inviteUrl;
  final DateTime? expiresAt;
}
