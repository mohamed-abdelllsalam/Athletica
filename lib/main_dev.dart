import 'package:athletica/athletica_app.dart';
import 'package:athletica/core/config/app_config.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env.dev');
  AppConfig.instance = AppConfig.dev();

  await Firebase.initializeApp();

  setupDependencies();
  runApp(const AthleticaApp());
}
