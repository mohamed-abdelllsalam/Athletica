/// Detailed client profile from `GET /coach/clients/:id`.
///
/// Contains full client info, active plans, and assessment answers.
class ClientDetail {
  const ClientDetail({
    required this.client,
    this.nutritionPlan,
    this.workoutPlan,
    // Local UI placeholder only: the backend no longer provides streaks
    // (DOC_7 removed `nutrition_streak`/`workout_streak`). Kept so the
    // existing Streak presentation keeps compiling unchanged.
    this.nutritionStreak = const Streak(current: 0),
    this.workoutStreak = const Streak(current: 0),
    this.questionsAnswers = const [],
    this.totalAnswers = 0,
    this.totalQuestions = 0,
  });

  final ClientProfile client;
  final NutritionPlanSummary? nutritionPlan;
  final WorkoutPlanSummary? workoutPlan;
  final Streak nutritionStreak;
  final Streak workoutStreak;
  final List<QuestionAnswer> questionsAnswers;
  final int totalAnswers;
  final int totalQuestions;

  /// Backend totals are the source of truth. Never use
  /// `questionsAnswers.length` (bilingual double answers can exceed it).
  bool get isQuestionsComplete =>
      totalQuestions > 0 && totalAnswers >= totalQuestions;
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

class WorkoutPlanSummary {
  const WorkoutPlanSummary({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    this.createdAt,
    this.startDate,
    this.cycleDays,
  });

  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? startDate;
  final int? cycleDays;
}

/// Local presentation placeholder for the Streak section.
///
/// The backend no longer sends streak data (DOC_7); values here are defaults
/// for display only and must not be treated as server state.
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
