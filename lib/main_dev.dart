import 'package:athletica/athletica_app.dart';
import 'package:athletica/core/config/app_config.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/notifications/domain/usecases/notification_inbox.dart';
import 'package:athletica/features/notifications/presentation/push_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env.dev');
  AppConfig.instance = AppConfig.dev();

  final packageInfo = await PackageInfo.fromPlatform();
  final release = 'athletica@${packageInfo.version}+${packageInfo.buildNumber}';

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.instance.sentryDsn;
      options.environment = 'development';
      options.sendDefaultPii = false;
      options.tracesSampleRate = 1.0;
      options.release = release;
    },
    appRunner: () async {
      setupDependencies();
      sl<NotificationInbox>().start();
      await sl<PushCoordinator>().initialize();

      runApp(const AthleticaApp());
    },
  );
}
