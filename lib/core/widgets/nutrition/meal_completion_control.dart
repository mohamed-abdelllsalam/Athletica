import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_cubit.dart';
import 'package:athletica/features/nutrition/presentation/cubits/nutrition_today_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class MealCompletionControl extends StatelessWidget {
  const MealCompletionControl({
    super.key,
    required this.mealLogId,
    this.wide = false,
  });
  final String mealLogId;
  final bool wide;
  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        NutritionTodayCubit,
        NutritionTodayState,
        ({bool completed, bool busy, bool exists})
      >(
        selector: (state) {
          final meal = state.meals.meals
              .where((m) => m.mealLogId == mealLogId)
              .firstOrNull;
          return (
            completed: meal?.completed ?? false,
            busy:
                state is NutritionTodayLoaded &&
                state.togglingMealLogIds.contains(mealLogId),
            exists: meal != null,
          );
        },
        builder: (context, value) {
          final label = value.completed
              ? 'Mark as Incomplete'
              : 'Mark Meal Complete';
          final onPressed = value.busy || !value.exists
              ? null
              : () => context.read<NutritionTodayCubit>().toggleComplete(
                  mealLogId,
                  !value.completed,
                );
          final icon = value.busy
              ? SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryPurple,
                  ),
                )
              : Icon(
                  value.completed
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: wide ? AppColors.textPrimary : AppColors.primaryPurple,
                  size: 28.sp,
                );
          if (wide) {
            return SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: Size(
                    48.w.clamp(48, double.infinity),
                    54.h.clamp(48, double.infinity),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                icon: icon,
                label: Text(
                  value.busy ? 'Updating meal…' : label,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Semantics(
            label: label,
            checked: value.completed,
            child: IconButton(
              tooltip: label,
              constraints: BoxConstraints(
                minWidth: 48.w.clamp(48, double.infinity),
                minHeight: 48.h.clamp(48, double.infinity),
              ),
              onPressed: onPressed,
              icon: icon,
            ),
          );
        },
      );
}

class NutritionCompletionFeedback extends StatelessWidget {
  const NutritionCompletionFeedback({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      BlocListener<NutritionTodayCubit, NutritionTodayState>(
        listenWhen: (previous, next) {
          if (next is! NutritionTodayLoaded) return false;
          final hasNewError =
              next.errorMessage != null &&
              (previous is! NutritionTodayLoaded ||
                  previous.errorMessage != next.errorMessage);
          final justCompleted =
              previous is NutritionTodayLoaded &&
              !previous.dayCompleted &&
              previous.togglingMealLogIds.isNotEmpty &&
              next.togglingMealLogIds.isEmpty &&
              next.errorMessage == null &&
              next.meals.meals.isNotEmpty &&
              next.dayCompleted;
          return hasNewError || justCompleted;
        },
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          final loaded = state as NutritionTodayLoaded;
          if (loaded.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(loaded.errorMessage!)));
            return;
          }
          showDialog<void>(
            context: context,
            builder: (dialogContext) => Dialog(
              backgroundColor: AppColors.cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Lottie.asset(
                        'assets/animations/done_nut.json',
                        width: 240,
                        height: 240,
                        repeat: false,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryPurple,
                          size: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nutrition completed!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You completed all your meals for today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: child,
      );
}
