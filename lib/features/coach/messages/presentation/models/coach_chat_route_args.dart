class CoachChatRouteArgs {
  const CoachChatRouteArgs({
    required this.clientId,
    required this.clientName,
    this.clientImageUrl,
    this.conversationId,
    this.coachClientId,
  });

  final String clientId;
  final String clientName;
  final String? clientImageUrl;
  final String? conversationId;
  final String? coachClientId;
}
