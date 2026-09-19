import 'exercise_search_summary.dart';
import 'exercise_search_result.dart';
import 'exercise_search_header.dart';
import 'dart:async';

import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/features/coach/plan/domain/entities/plan_exercise.dart';
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<WorkoutExercisesCubit>().searchLibrary(value);
    });
  }

  List<PlanExercise> get _selected => _loaded
      .where((e) => _selectedIds.contains(e.id))
      .map(
        (e) => PlanExercise(
          id: e.id,
          name: buildBilingualLabel(
            primary: e.nameEn,
            arabic: e.nameAr,
            english: e.nameEn,
          ),
          thumbnailUrl: e.thumbnailUrlMale,
          videoUrlMale: e.videoUrlMale,
          videoUrlFemale: e.videoUrlFemale,
        ),
      )
      .toList();

  String get _summaryText => _selected.map((e) => e.name).join(' / ');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        CoachExerciseSearchHeader(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onBack: () => Navigator.pop(context, _selected),
          onClear: () => setState(() {
            _selectedIds.clear();
            _searchController.clear();
            context.read<WorkoutExercisesCubit>().load(
              filters: const WorkoutExerciseFilters(),
            );
          }),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: BlocConsumer<WorkoutExercisesCubit, WorkoutExercisesState>(
            listener: (context, state) {
              if (state is WorkoutExercisesLoaded) _loaded = state.items;
            },
            builder: (context, state) => switch (state) {
              WorkoutExercisesInitial() || WorkoutExercisesLoading() =>
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
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
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
              WorkoutExercisesLoaded(:final items) =>
                items.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises found',
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final exercise = items[index];
                          final selected = _selectedIds.contains(exercise.id);
                          return CoachExerciseSearchResult(
                            exercise: exercise,
                            selected: selected,
                            onPlay: () => showExerciseVideoDialog(
                              context,
                              title: buildBilingualLabel(
                                primary: exercise.nameEn,
                                arabic: exercise.nameAr,
                                english: exercise.nameEn,
                              ),
                              videoUrl: resolveExerciseVideoUrl(
                                maleUrl: exercise.videoUrlMale,
                                femaleUrl: exercise.videoUrlFemale,
                              ),
                              thumbnailUrl: exercise.thumbnailUrlMale,
                            ),
                            onToggle: () => setState(() {
                              if (selected) {
                                _selectedIds.remove(exercise.id);
                              } else {
                                _selectedIds.add(exercise.id);
                              }
                            }),
                          );
                        },
                      ),
            },
          ),
        ),
        if (_selected.isNotEmpty)
          CoachExerciseSearchSummary(
            summaryText: _summaryText,
            onSubmit: () => Navigator.pop(context, _selected),
          ),
      ],
    );
  }
}
