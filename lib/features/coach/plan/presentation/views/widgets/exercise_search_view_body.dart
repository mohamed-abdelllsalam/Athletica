import 'dart:async';

import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/plan_exercise.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Exercise search backed by `GET /workout/exercises`.
/// Visuals unchanged; returns selected [PlanExercise]s with real API ids.
class ExerciseSearchViewBody extends StatefulWidget {
  const ExerciseSearchViewBody({super.key});

  @override
  State<ExerciseSearchViewBody> createState() => _ExerciseSearchViewBodyState();
}

class _ExerciseSearchViewBodyState extends State<ExerciseSearchViewBody> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  final Set<String> _selectedIds = {};
  List<WorkoutExerciseEntry> _loaded = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool _isArabic() =>
      Localizations.localeOf(context).languageCode == 'ar';

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<WorkoutExercisesCubit>().load(
            filters: WorkoutExerciseFilters(
              search: value.isEmpty ? null : value,
            ),
          );
    });
  }

  List<PlanExercise> get _selected => _loaded
      .where((e) => _selectedIds.contains(e.id))
      .map((e) => PlanExercise(id: e.id, name: e.localizedName(_isArabic())))
      .toList();

  String get _summaryText =>
      _selected.map((e) => e.name).join(' / ');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _RoundedIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context, _selected),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.search,
                          color: AppColors.textSecondary, size: 20.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              _RoundedIconButton(
                icon: Icons.delete_outline,
                onTap: () => setState(() {
                  _selectedIds.clear();
                  _searchController.clear();
                  context.read<WorkoutExercisesCubit>().load(
                        filters: const WorkoutExerciseFilters(),
                      );
                }),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: BlocConsumer<WorkoutExercisesCubit, WorkoutExercisesState>(
            listener: (context, state) {
              if (state is WorkoutExercisesLoaded) _loaded = state.items;
            },
            builder: (context, state) => switch (state) {
              WorkoutExercisesInitial() ||
              WorkoutExercisesLoading() =>
                const Center(child: CircularProgressIndicator()),
              WorkoutExercisesError(:final message) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.medium14(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () =>
                              context.read<WorkoutExercisesCubit>().load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              WorkoutExercisesLoaded(:final items) => items.isEmpty
                  ? Center(
                      child: Text(
                        'No exercises found',
                        style: AppTextStyles.medium14(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final exercise = items[index];
                        final selected =
                            _selectedIds.contains(exercise.id);
                        return Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              const ExerciseThumbnail(size: 72),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.localizedName(_isArabic()),
                                      style: AppTextStyles.medium14(context)
                                          .copyWith(
                                              color: AppColors.textPrimary),
                                    ),
                                    if (exercise
                                        .primaryMuscle.isNotEmpty) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        exercise.primaryMuscle,
                                        style:
                                            AppTextStyles.meduim11(context)
                                                .copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  if (selected) {
                                    _selectedIds.remove(exercise.id);
                                  } else {
                                    _selectedIds.add(exercise.id);
                                  }
                                }),
                                child: Icon(
                                  selected
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: selected
                                      ? AppColors.primaryBlue
                                      : AppColors.textSecondary,
                                  size: 22.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            },
          ),
        ),
        if (_selected.isNotEmpty)
          _SummaryBar(
            summaryText: _summaryText,
            onSubmit: () => Navigator.pop(context, _selected),
          ),
      ],
    );
  }
}

class _RoundedIconButton extends StatelessWidget {
  const _RoundedIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summaryText, required this.onSubmit});

  final String summaryText;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Summary Of Training :',
                style: AppTextStyles.meduim12(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: 200.w,
                child: Text(
                  summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meduim12(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Submit',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
