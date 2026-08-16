class CoachHomeStats {
  const CoachHomeStats({
    required this.totalClients,
    required this.activeClients,
    required this.expiringSubscriptions,
  });

  final int totalClients;
  final int activeClients;
  final int expiringSubscriptions;
}
