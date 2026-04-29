import 'package:athletica/core/config/app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.instance.baseUrl;

  static const String registerClient = 'auth/register/client';
  static const String registerTrainer = 'auth/register/trainer';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String clientIntakeAnswers = 'client-intake/answers';
  static const String clientIntakeQuestions = 'client-intake/questions';
  static const String clientProfile = 'client-profiles/me';
}
