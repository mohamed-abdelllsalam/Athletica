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

  static const String foods = 'foods/getAll';
  static const String foodCategories = 'foods/categories';

  static const String mealTemplates = 'templates';
  static String mealTemplateDays(String templateId) =>
      'templates/days/$templateId';
  static String mealTemplateItems(String dayId) => 'templates/items/$dayId';
}
