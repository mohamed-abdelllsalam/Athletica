import 'package:athletica/features/settings/presentation/views/widgets/settings_view_body.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  static const String routeName = 'settingsView';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SettingsViewBody(),
    );
  }
}
