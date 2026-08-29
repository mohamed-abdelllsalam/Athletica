/// Detailed client profile from `GET /coach/clients/:id`.
///
/// Contains full client info, active plans, streaks, and assessment answers.
class ClientDetail {
  const ClientDetail({
    required this.client,
    this.nutritionPlan,
    this.workoutPlan,
    required this.nutritionStreak,
    required this.workoutStreak,
    this.questionsAnswers = const [],
  });

  final ClientProfile client;
  final NutritionPlanSummary? nutritionPlan;
  final dynamic workoutPlan; // null until workout feature ships
  final Streak nutritionStreak;
  final Streak workoutStreak;
  final List<QuestionAnswer> questionsAnswers;
}

class ClientProfile {
  const ClientProfile({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.profileImage,
    this.gender,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.goal,
    this.assignedAt,
  });

  final String id;
  final String username;
  final String email;
  final String? name;
  final String? profileImage;
  final String? gender;
  final DateTime? birthDate;
  final num? heightCm;
  final num? weightKg;
  final String? goal;
  final DateTime? assignedAt;

  String get displayName => name ?? username;
}

class NutritionPlanSummary {
  const NutritionPlanSummary({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
}

class Streak {
  const Streak({
    required this.current,
    this.lastDate,
  });

  final int current;
  final String? lastDate;
}

class QuestionAnswer {
  const QuestionAnswer({
    required this.id,
    required this.questionId,
    required this.answer,
    this.answerText,
    required this.question,
    required this.questionType,
    this.createdAt,
  });

  final String id;
  final String questionId;
  final String answer;
  final String? answerText;
  final String question;
  final String questionType;
  final DateTime? createdAt;
}
