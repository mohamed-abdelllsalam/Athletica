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
        baseUrl: 'https://athletica-six.vercel.app/api/v1/',
        appName: 'Athletica Dev',
      );

  factory AppConfig.prod() => AppConfig._(
        flavor: Flavor.prod,
        baseUrl: 'https://athletica-six.vercel.app/api/v1/',
        appName: 'Athletica',
      );

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;
}
