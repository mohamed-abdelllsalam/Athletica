import 'package:athletica/features/notifications/presentation/push_coordinator.dart';
import 'package:athletica/features/notifications/domain/usecases/notification_inbox.dart';
import 'package:athletica/athletica_app.dart';
import 'package:athletica/core/config/app_config.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env.dev');
  AppConfig.instance = AppConfig.dev();

  setupDependencies();
  sl<NotificationInbox>().start();
  await sl<PushCoordinator>().initialize();
  runApp(const AthleticaApp());
}
