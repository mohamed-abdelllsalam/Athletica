class CoachClient {
  const CoachClient({
    required this.id,
    required this.name,
    required this.joinedMonthsAgo,
    required this.subscriptionActive,
    this.imageAsset,
    this.heightCm,
    this.weightKg,
    this.goals = const [],
    this.sessionHistory = const [],
  });

  final String id;
  final String name;
  final int joinedMonthsAgo;
  final bool subscriptionActive;
  final String? imageAsset;
  final int? heightCm;
  final int? weightKg;
  final List<String> goals;
  final List<ClientSession> sessionHistory;
}

class ClientSession {
  const ClientSession({
    required this.sessionNumber,
    required this.title,
    required this.date,
  });

  final int sessionNumber;
  final String title;
  final String date;
}
