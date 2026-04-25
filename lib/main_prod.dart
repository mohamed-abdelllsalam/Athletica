import 'package:athletica/athletica_app.dart';
import 'package:athletica/core/config/app_config.dart';
import 'package:athletica/core/di/injection_container.dart';
import 'package:flutter/material.dart';

void main() {
  AppConfig.instance = AppConfig.prod();
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const AthleticaApp());
}
