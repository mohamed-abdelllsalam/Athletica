import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/pdf_opener.dart';
import 'package:athletica/features/achievements/presentation/cubits/client_coach_achievements_cubit.dart';
import 'package:athletica/features/achievements/presentation/cubits/client_coach_achievements_state.dart';
import 'package:athletica/features/achievements/presentation/views/widgets/achievement_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientCoachAchievementsSection extends StatefulWidget {
  const ClientCoachAchievementsSection({super.key});

  @override
  State<ClientCoachAchievementsSection> createState() =>
      _ClientCoachAchievementsSectionState();
}

class _ClientCoachAchievementsSectionState
    extends State<ClientCoachAchievementsSection> {
  @override
  void initState() {
    super.initState();
    context.read<ClientCoachAchievementsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      ClientCoachAchievementsCubit,
      ClientCoachAchievementsState
    >(
      listenWhen: (previous, current) =>
          current is ClientCoachAchievementsError,
      listener: (context, state) {
        if (state is! ClientCoachAchievementsError) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
      },
      child:
          BlocBuilder<
            ClientCoachAchievementsCubit,
            ClientCoachAchievementsState
          >(
            builder: (context, state) {
              final achievements = state is ClientCoachAchievementsLoaded
                  ? state.achievements
                  : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach certificates',
                    style: AppTextStyles.bold20(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 12.h),
                  if (state is ClientCoachAchievementsInitial ||
                      state is ClientCoachAchievementsLoading)
                    const LinearProgressIndicator(color: AppColors.primaryBlue)
                  else if (achievements != null)
                    AchievementList(
                      achievements: achievements,
                      onOpen: (achievement) => openPdfFromContext(
                        context,
                        achievement.fileUrl,
                        title: achievement.title,
                      ),
                    )
                  else
                    Text(
                      state is ClientCoachAchievementsError
                          ? state.message
                          : 'Unable to load certificates.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                ],
              );
            },
          ),
    );
  }
}
