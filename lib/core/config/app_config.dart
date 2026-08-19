import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, prod }

class AppConfig {
  AppConfig._({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
  });

  final Flavor flavor;
  final String baseUrl;
  final String appName;

  static late AppConfig instance;

  factory AppConfig.dev() => AppConfig._(
        flavor: Flavor.dev,
        baseUrl: _envValue(
          'BASE_URL',
          fallback: 'https://athletica-bakend.vercel.app/api/v1/',
        ),
        appName: _envValue('APP_NAME', fallback: 'Athletica Dev'),
      );

  factory AppConfig.prod() => AppConfig._(
        flavor: Flavor.prod,
        baseUrl: _envValue(
          'BASE_URL',
          fallback: 'https://athletica-bakend.vercel.app/api/v1/',
        ),
        appName: _envValue('APP_NAME', fallback: 'Athletica'),
      );

  static String _envValue(String key, {required String fallback}) {
    final value = dotenv.maybeGet(key);
    return (value == null || value.trim().isEmpty) ? fallback : value;
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;
}