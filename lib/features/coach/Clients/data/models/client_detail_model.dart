import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';

/// Parses `GET /coach/clients/:id` response.
class ClientDetailModel {
  const ClientDetailModel({
    required this.client,
    this.nutritionPlan,
    this.workoutPlan,
    required this.nutritionStreak,
    required this.workoutStreak,
    this.questionsAnswers = const [],
  });

  final ClientProfileModel client;
  final NutritionPlanSummaryModel? nutritionPlan;
  final dynamic workoutPlan;
  final StreakModel nutritionStreak;
  final StreakModel workoutStreak;
  final List<QuestionAnswerModel> questionsAnswers;

  factory ClientDetailModel.fromJson(Map<String, dynamic> json) {
    final clientData = json['client'] as Map<String, dynamic>? ?? {};
    final nutritionPlanData = json['nutrition_plan'] as Map<String, dynamic>?;
    final nutritionStreakData =
        json['nutrition_streak'] as Map<String, dynamic>? ?? {};
    final workoutStreakData =
        json['workout_streak'] as Map<String, dynamic>? ?? {};
    final questionsAnswersData = json['questions_answers'] as List<dynamic>? ?? [];

    return ClientDetailModel(
      client: ClientProfileModel.fromJson(clientData),
      nutritionPlan: nutritionPlanData != null
          ? NutritionPlanSummaryModel.fromJson(nutritionPlanData)
          : null,
      workoutPlan: json['workout_plan'],
      nutritionStreak: StreakModel.fromJson(nutritionStreakData),
      workoutStreak: StreakModel.fromJson(workoutStreakData),
      questionsAnswers: questionsAnswersData
          .map((e) => QuestionAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ClientDetail toEntity() => ClientDetail(
        client: client.toEntity(),
        nutritionPlan: nutritionPlan?.toEntity(),
        workoutPlan: workoutPlan,
        nutritionStreak: nutritionStreak.toEntity(),
        workoutStreak: workoutStreak.toEntity(),
        questionsAnswers:
            questionsAnswers.map((e) => e.toEntity()).toList(),
      );
}

class ClientProfileModel {
  const ClientProfileModel({
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

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    return ClientProfileModel(
      id: json['id'] as String? ?? '',
      username: userData['username'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      name: userData['name'] as String?,
      profileImage: json['profile_image'] as String?,
      gender: json['gender'] as String?,
      birthDate: DateTime.tryParse(json['birth_date'] as String? ?? ''),
      heightCm: json['height'] as num?,
      weightKg: json['weight'] as num?,
      goal: json['goal'] as String?,
      assignedAt: DateTime.tryParse(json['assigned_at'] as String? ?? ''),
    );
  }

  ClientProfile toEntity() => ClientProfile(
        id: id,
        username: username,
        email: email,
        name: name,
        profileImage: profileImage,
        gender: gender,
        birthDate: birthDate,
        heightCm: heightCm,
        weightKg: weightKg,
        goal: goal,
        assignedAt: assignedAt,
      );
}

class NutritionPlanSummaryModel {
  const NutritionPlanSummaryModel({
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

  factory NutritionPlanSummaryModel.fromJson(Map<String, dynamic> json) {
    return NutritionPlanSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  NutritionPlanSummary toEntity() => NutritionPlanSummary(
        id: id,
        title: title,
        description: description,
        isActive: isActive,
        createdAt: createdAt,
      );
}

class StreakModel {
  const StreakModel({
    required this.current,
    this.lastDate,
  });

  final int current;
  final String? lastDate;

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      current: json['current'] as int? ?? 0,
      lastDate: json['last_date'] as String?,
    );
  }

  Streak toEntity() => Streak(
        current: current,
        lastDate: lastDate,
      );
}

class QuestionAnswerModel {
  const QuestionAnswerModel({
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

  factory QuestionAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnswerModel(
      id: json['id'] as String? ?? '',
      questionId: json['question_id'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      answerText: json['answer_text'] as String?,
      question: json['question'] as String? ?? '',
      questionType: json['question_type'] as String? ?? 'text',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  QuestionAnswer toEntity() => QuestionAnswer(
        id: id,
        questionId: questionId,
        answer: answer,
        answerText: answerText,
        question: question,
        questionType: questionType,
        createdAt: createdAt,
      );
}
