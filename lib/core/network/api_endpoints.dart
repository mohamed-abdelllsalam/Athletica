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
          path == endpoint || path == '/$endpoint' || path.endsWith('/$endpoint'),
    );
  }

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
          String templateId, String mealId, String foodId) =>
      'nutrition/templates/$templateId/meals/$mealId/foods/$foodId';
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
          String planId, String mealId, String foodId) =>
      'nutrition/plans/$planId/meals/$mealId/foods/$foodId';

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
}
