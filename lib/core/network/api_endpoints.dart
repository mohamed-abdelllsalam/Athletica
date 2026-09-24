import 'package:athletica/core/config/app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.instance.baseUrl;

  static const String signup = 'auth/signup';
  static const String verifyEmail = 'auth/verify-email';
  static const String resendVerification = 'auth/resend-verification';
  static const String login = 'auth/login';
  static const String requestPasswordReset = 'auth/reset-password';
  static const String confirmPasswordReset = 'auth/reset-password/confirm';
  static const String logout = 'auth/logout';

  // Realtime messaging contract (CHAT_DOC.md).
  static const String messagingConversations = 'messaging/conversations';
  static String messagingConversation(String id) =>
      'messaging/conversations/$id';
  static String messagingMessages(String id) =>
      '${messagingConversation(id)}/messages';
  static String messagingFirstMessage(String coachClientId) =>
      '$messagingConversations/by-coach-client/$coachClientId/messages';
  static const String ablyToken = 'realtime/ably-token';

  static const List<String> publicAuthPaths = [
    signup,
    verifyEmail,
    resendVerification,
    login,
    requestPasswordReset,
    confirmPasswordReset,
  ];

  static bool isPublicAuthPath(String uriPath) {
    final path = Uri.parse(uriPath).path;
    return publicAuthPaths.any(
      (endpoint) =>
          path == endpoint ||
          path == '/$endpoint' ||
          path.endsWith('/$endpoint'),
    );
  }

  // ── Profile ─────────────────────────────────────────────────────────────
  static const String profile = 'profile';
  static const String profileImage = 'profile/image';

  static const String coachAchievements = 'coach/achievements';
  static String coachAchievement(String id) => 'coach/achievements/$id';
  static const String clientCoachAchievements = 'client/coach/achievements';

  static const String clientQuestions = 'client/questions';
  static const String clientAnswers = 'client/answers';
  static const String clientProfile = 'client-profiles/me';
  static String trainerProfile(String trainerId) =>
      'trainer-profiles/getById/$trainerId';
  static String trainerClients(String trainerId) =>
      'trainer-clients/getAllByTrainerId/$trainerId';
  static const String trainerInviteCodes = 'trainer-invite-codes';

  static const String createWorkoutTemplate = 'workout-templates/create';
  static String workoutTemplates(String trainerId) =>
      'workout-templates/getAll/$trainerId';

  static const String workoutTemplateDays = 'workout-template-days';
  static String workoutTemplateDayById(String dayId) =>
      'workout-template-days/getById/$dayId';

  static const String workoutTemplateItems = 'workout-template-items';

  // ── Nutrition (documented contract: NUTRITION_API_FOR_FLUTTER.md) ──────────

  // Food catalog
  static const String nutritionFoods = 'nutrition/foods';
  static String nutritionFood(String id) => 'nutrition/foods/$id';
  static const String nutritionFoodCategories = 'nutrition/food-categories';

  // Templates (coach)
  static const String nutritionTemplates = 'nutrition/templates';
  static String nutritionTemplate(String templateId) =>
      'nutrition/templates/$templateId';
  static String nutritionTemplateMeals(String templateId) =>
      'nutrition/templates/$templateId/meals';
  static String nutritionTemplateMealsReorder(String templateId) =>
      'nutrition/templates/$templateId/meals/reorder';
  static String nutritionTemplateMeal(String templateId, String mealId) =>
      'nutrition/templates/$templateId/meals/$mealId';
  static String nutritionTemplateMealFoods(String templateId, String mealId) =>
      'nutrition/templates/$templateId/meals/$mealId/foods';
  static String nutritionTemplateMealFood(
    String templateId,
    String mealId,
    String foodId,
  ) => 'nutrition/templates/$templateId/meals/$mealId/foods/$foodId';
  static String assignNutritionTemplate(String templateId) =>
      'nutrition/templates/$templateId/assign';

  // Plans (coach)
  static const String nutritionPlans = 'nutrition/plans';
  static String nutritionPlan(String planId) => 'nutrition/plans/$planId';
  static String nutritionPlanMeals(String planId) =>
      'nutrition/plans/$planId/meals';
  static String nutritionPlanMealsReorder(String planId) =>
      'nutrition/plans/$planId/meals/reorder';
  static String nutritionPlanMeal(String planId, String mealId) =>
      'nutrition/plans/$planId/meals/$mealId';
  static String nutritionPlanMealFoods(String planId, String mealId) =>
      'nutrition/plans/$planId/meals/$mealId/foods';
  static String nutritionPlanMealFood(
    String planId,
    String mealId,
    String foodId,
  ) => 'nutrition/plans/$planId/meals/$mealId/foods/$foodId';

  // Coach-client assignment (documented contract: NUTRITION_API_FOR_FLUTTER.md)
  static const String coachClients = 'coach/clients';
  static String coachClient(String coachClientId) =>
      'coach/clients/$coachClientId';
  static const String coachInvite = 'coach/invite';
  static const String coachRequests = 'coach/requests';
  static String coachRequestAccept(String requestId) =>
      'coach/requests/$requestId/accept';
  static String coachRequestReject(String requestId) =>
      'coach/requests/$requestId/reject';

  // Client side of the assignment flow
  static const String coachClientRequests = 'coach-requests';
  static const String clientCoach = 'client/coach';
  static const String clientLeaveCoach = 'client/leave-coach';

  // Client nutrition view (documented contract: NUTRITION_API_FOR_FLUTTER.md)
  static const String nutritionToday = 'nutrition/today';
  static const String nutritionMyPlans = 'nutrition/my/plans';
  static String nutritionMyPlan(String planId) => 'nutrition/my/plans/$planId';
  static const String nutritionHistory = 'nutrition/history';
  static String nutritionMealComplete(String mealLogId) =>
      'nutrition/meals/$mealLogId/complete';
  static String nutritionMealUncomplete(String mealLogId) =>
      'nutrition/meals/$mealLogId/uncomplete';
  static const String nutritionStreak = 'nutrition/streak';
  static String coachNutritionStreak(String coachClientId) =>
      'nutrition/clients/$coachClientId/streak';

  // Client assigned plans (workout + nutrition)
  static const String clientAssigned = 'client/assigned';
  static String assignWorkoutTemplate(String templateId) =>
      'workout-templates/$templateId/assign';
  static String assignNutritionToClient(String templateId) =>
      'nutrition/templates/$templateId/assign';

  // ── Workout (documented contract: WORKOUT_API_DOC_1.md) ──────────────
  // All routes live under /workout. Dio baseUrl already ends with /api/v1/,
  // so relative paths resolve to /api/v1/workout/... (no double prefix).

  // Exercise library (any authenticated user)
  static const String workoutExercises = 'workout/exercises';
  static String workoutExercise(String id) => 'workout/exercises/$id';

  // Templates (coach)
  static const String workoutTemplatesV1 = 'workout/templates';
  static String workoutTemplate(String templateId) =>
      'workout/templates/$templateId';
  static String workoutTemplateDaysV1(String templateId) =>
      'workout/templates/$templateId/days';
  static String workoutTemplateDaysReorder(String templateId) =>
      'workout/templates/$templateId/days/reorder';
  static String workoutTemplateDay(String templateId, String dayId) =>
      'workout/templates/$templateId/days/$dayId';
  static String workoutTemplateDayExercises(String templateId, String dayId) =>
      'workout/templates/$templateId/days/$dayId/exercises';
  static String workoutTemplateDayExercise(
    String templateId,
    String dayId,
    String exerciseId,
  ) => 'workout/templates/$templateId/days/$dayId/exercises/$exerciseId';
  static String assignWorkoutTemplateV1(String templateId) =>
      'workout/templates/$templateId/assign';

  // Plans (coach)
  static const String workoutPlans = 'workout/plans';
  static String workoutPlan(String planId) => 'workout/plans/$planId';
  static String workoutPlanDays(String planId) => 'workout/plans/$planId/days';
  static String workoutPlanDaysReorder(String planId) =>
      'workout/plans/$planId/days/reorder';
  static String workoutPlanDay(String planId, String dayId) =>
      'workout/plans/$planId/days/$dayId';
  static String workoutPlanDayExercises(String planId, String dayId) =>
      'workout/plans/$planId/days/$dayId/exercises';
  static String workoutPlanDayExercise(
    String planId,
    String dayId,
    String exerciseId,
  ) => 'workout/plans/$planId/days/$dayId/exercises/$exerciseId';

  // ── Check-In (documented contract: CHECK_IN.md) ─────────────────────
  // Coach prefix /coach/checkin, client prefix /client/checkin.
  // Dio baseUrl already ends with /api/v1/, so relative paths resolve
  // to /api/v1/coach/checkin/... and /api/v1/client/checkin/...
  static const String coachCheckinQuestions = 'coach/checkin/questions';
  static String coachCheckinQuestion(String questionId) =>
      'coach/checkin/questions/$questionId';
  static const String coachCheckinQuestionsReorder =
      'coach/checkin/questions/reorder';
  static const String coachCheckinAssign = 'coach/checkin/assign';
  static String coachCheckinSubmissions(String coachClientId) =>
      'coach/checkin/clients/$coachClientId/submissions';
  static String coachCheckinSubmission(
    String coachClientId,
    String submissionId,
  ) => 'coach/checkin/clients/$coachClientId/submissions/$submissionId';

  static String coachCheckinStatus(String coachClientId) =>
      'coach/checkin/clients/$coachClientId/status';

  // Note the backend spelling: hasassign (no 'd').
  static const String clientCheckinHasAssign = 'client/checkin/hasassign';
  static const String clientCheckinQuestions = 'client/checkin/questions';
  static const String clientCheckinSubmit = 'client/checkin/submit';
  static const String clientCheckinSubmissions = 'client/checkin/submissions';
  static String clientCheckinSubmission(String submissionId) =>
      'client/checkin/submissions/$submissionId';

  // Client daily tracking
  static const String workoutToday = 'workout/today';
  static const String workoutMyPlans = 'workout/my/plans';
  static String workoutMyPlan(String planId) => 'workout/my/plans/$planId';
  static const String workoutHistory = 'workout/history';
  static const String workoutStreak = 'workout/streak';
  static String coachWorkoutStreak(String coachClientId) =>
      'workout/clients/$coachClientId/streak';
  static String workoutExerciseComplete(String logId) =>
      'workout/exercises/$logId/complete';
  static String workoutExerciseUncomplete(String logId) =>
      'workout/exercises/$logId/uncomplete';
}
