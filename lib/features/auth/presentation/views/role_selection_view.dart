import 'package:athletica/features/auth/presentation/views/widgets/role_selection_view_body.dart';
import 'package:flutter/material.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  static const String routeName = 'roleSelectionView';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: RoleSelectionViewBody());
  }
}
