class ChatRouteArgs {
  const ChatRouteArgs({
    required this.title,
    this.conversationId,
    this.coachClientId,
    this.clientId,
    this.canStartConversation = false,
  });

  final String title;
  final String? conversationId;
  final String? coachClientId;
  final String? clientId;
  final bool canStartConversation;
}
