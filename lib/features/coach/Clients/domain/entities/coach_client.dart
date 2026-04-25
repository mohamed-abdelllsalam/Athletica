class CoachClient {
  const CoachClient({
    required this.id,
    required this.name,
    required this.joinedMonthsAgo,
    required this.subscriptionActive,
    this.subscriptionPercent,
    this.expiresInDays,
    this.isRenewed,
    this.imageAsset,
    this.heightCm,
    this.weightKg,
    this.goals = const [],
    this.sessionHistory = const [],
    this.assignedWorkoutPlan,
    this.workoutPlanSubtitle,
    this.assignedDietPlan,
    this.dietPlanSubtitle,
    this.subscriptionDurationMonths,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.assessmentQuestions = const [],
  });

  final String id;
  final String name;
  final int joinedMonthsAgo;
  final bool subscriptionActive;
  final int? subscriptionPercent;
  final int? expiresInDays;
  final bool? isRenewed;
  final String? imageAsset;
  final int? heightCm;
  final int? weightKg;
  final List<String> goals;
  final List<ClientSession> sessionHistory;
  final String? assignedWorkoutPlan;
  final String? workoutPlanSubtitle;
  final String? assignedDietPlan;
  final String? dietPlanSubtitle;
  final int? subscriptionDurationMonths;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final List<ClientHealthQuestion> assessmentQuestions;
}

class ClientHealthQuestion {
  const ClientHealthQuestion({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
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
