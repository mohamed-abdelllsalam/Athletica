import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assigned_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignedView extends StatelessWidget {
  const AssignedView({super.key});

  static const String routeName = 'assigned-view';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AssignedCubit>()..loadAssigned(),
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: AssignedViewBody()),
      ),
    );
  }
}
