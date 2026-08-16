class CoachInviteCode {
  const CoachInviteCode({
    required this.id,
    required this.trainerId,
    required this.code,
    required this.totalClients,
    required this.inviteLink,
  });

  final String id;
  final String trainerId;
  final String code;
  final int totalClients;
  final String inviteLink;
}
