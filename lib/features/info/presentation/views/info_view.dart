import 'package:athletica/features/info/presentation/views/widgets/info_view_body.dart';
import 'package:flutter/material.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key});
  static const String routeName = 'info';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const InfoViewBody());
  }
}
