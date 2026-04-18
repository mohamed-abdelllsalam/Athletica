import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/coach_subscription_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_subscription_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachSubscriptionView extends StatelessWidget {
  const CoachSubscriptionView({super.key});

  static const String routeName = 'coach-subscription';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoachSubscriptionCubit>(),
      child: const CoachSubscriptionViewBody(),
    );
  }
}
