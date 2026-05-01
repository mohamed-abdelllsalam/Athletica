import 'package:athletica/core/config/app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.instance.baseUrl;

  static const String registerClient = 'auth/register/client';
  static const String registerTrainer = 'auth/register/trainer';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String clientIntakeQuestions = 'client-intake/questions';
  static const String clientIntakeAnswers = 'client-intake/answers';
  static String clientIntakeAnswersByClient(String clientId) =>
      'client-intake/answers/client/$clientId';
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
}
