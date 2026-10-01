import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/achievements/presentation/cubits/coach_achievements_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_complete_profile_view_body.dart';
import 'package:athletica/features/complete_profile/presentation/cubits/complete_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachCompleteProfileView extends StatelessWidget {
  const CoachCompleteProfileView({super.key});

  static const String routeName = 'coach-complete-profile';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CoachAchievementsCubit>()..load()),
        BlocProvider(create: (_) => sl<CompleteProfileCubit>()),
      ],
      child: const CoachCompleteProfileViewBody(),
    );
  }
}
