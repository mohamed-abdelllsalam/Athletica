import 'dart:async';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Exercise library backed by `GET /workout/exercises`.
/// Visuals unchanged; data comes from the API (search + muscle filter).
/// Returns newly picked [LibraryExercise]s mapped from API entries.
class ExerciseLibraryPickerView extends StatelessWidget {
  const ExerciseLibraryPickerView({super.key, required this.alreadyAddedIds});

  final Set<String> alreadyAddedIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutExercisesCubit>()..load(),
      child: _PickerBody(alreadyAddedIds: alreadyAddedIds),
    );
  }
}

class _PickerBody extends StatefulWidget {
  const _PickerBody({required this.alreadyAddedIds});

  final Set<String> alreadyAddedIds;

  @override
  State<_PickerBody> createState() => _PickerBodyState();
}

class _PickerBodyState extends State<_PickerBody> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  String _selectedMuscle = 'All';
  late Set<String> _selectedIds;
  List<WorkoutExerciseEntry> _loaded = [];

  static const List<String> _muscles = [
    'All',
    'Back',
    'Chest',
    'Shoulder',
    'Arm',
    'Core',
    'Legs',
  ];

  /// Rail label → backend `bodyPart` exact-match value (DOC_6 §4.1).
  /// Unknown labels resolve to null (= unfiltered), never to a bad value.
  static const Map<String, String> _muscleToBodyPart = {
    'Back': 'back',
    'Chest': 'chest',
    'Shoulder': 'shoulders',
    'Arm': 'upper arms',
    'Core': 'waist',
    'Legs': 'upper legs',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedIds = Set.from(widget.alreadyAddedIds);
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
      final muscle = _selectedMuscle == 'All' ? null : _selectedMuscle;
      context.read<WorkoutExercisesCubit>().searchLibrary(
            value,
            bodyPart: muscle == null ? null : _muscleToBodyPart[muscle],
          );
    });
  }

  void _onMuscleSelect(String muscle) {
    setState(() => _selectedMuscle = muscle);
    final selected = muscle == 'All' ? null : muscle;
    context.read<WorkoutExercisesCubit>().searchLibrary(
          _searchController.text,
          bodyPart: selected == null ? null : _muscleToBodyPart[selected],
        );
  }

  int get _newCount => _selectedIds.difference(widget.alreadyAddedIds).length;

  void _toggle(WorkoutExerciseEntry ex) {
    setState(() {
      if (_selectedIds.contains(ex.id)) {
        if (!widget.alreadyAddedIds.contains(ex.id)) {
          _selectedIds.remove(ex.id);
        }
      } else {
        _selectedIds.add(ex.id);
      }
    });
  }

  void _submit() {
    final picked = _loaded
        .where(
          (e) =>
              _selectedIds.contains(e.id) &&
              !widget.alreadyAddedIds.contains(e.id),
        )
        .map(
          (e) => LibraryExercise(
            id: e.id,
            name: e.nameEn,
            nameEn: e.nameEn,
            nameAr: e.nameAr,
            muscleGroup: e.primaryMuscle,
            thumbnailUrl: e.thumbnailUrlMale,
            videoUrlMale: e.videoUrlMale,
            videoUrlFemale: e.videoUrlFemale,
          ),
        )
        .toList();
    Navigator.pop(context, picked);
  }

  @override
  Widget build(BuildContext context) {
    // 'All' stays first: selecting it clears the muscle filter and reloads
    // the full library.
    final muscles = _muscles;

    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context, <LibraryExercise>[])),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _SearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        BlocConsumer<
                          WorkoutExercisesCubit,
                          WorkoutExercisesState
                        >(
                          listener: (context, state) {
                            if (state is WorkoutExercisesLoaded) {
                              _loaded = state.items;
                            }
                          },
                          builder: (context, state) => switch (state) {
                            WorkoutExercisesInitial() ||
                            WorkoutExercisesLoading() => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            WorkoutExercisesError(:final message) => Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.medium14(context)
                                          .copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                    SizedBox(height: 12.h),
                                    TextButton(
                                      onPressed: () => context
                                          .read<WorkoutExercisesCubit>()
                                          .load(),
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
                                        style: AppTextStyles.medium14(context)
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    )
                                  : ListView.separated(
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                        16.w,
                                        0,
                                        6.w,
                                        100.h,
                                      ),
                                      itemCount: items.length,
                                      separatorBuilder: (_, _) =>
                                          SizedBox(height: 10.h),
                                      itemBuilder: (context, index) {
                                        final ex = items[index];
                                        final alreadyAdded = widget
                                            .alreadyAddedIds
                                            .contains(ex.id);
                                        final isSelected = _selectedIds
                                            .contains(ex.id);
                                        final name = buildBilingualLabel(
                                          primary: ex.nameEn,
                                          arabic: ex.nameAr,
                                          english: ex.nameEn,
                                        );
                                        return _ExerciseLibraryCard(
                                          name: name,
                                          muscle: ex.primaryMuscle,
                                          thumbnailUrl: ex.thumbnailUrlMale,
                                          isSelected: isSelected,
                                          alreadyAdded: alreadyAdded,
                                          onTap: () => _toggle(ex),
                                          onPlay: () =>
                                              showExerciseVideoDialog(
                                            context,
                                            title: name,
                                            videoUrl: resolveExerciseVideoUrl(
                                              maleUrl: ex.videoUrlMale,
                                              femaleUrl: ex.videoUrlFemale,
                                            ),
                                            thumbnailUrl: ex.thumbnailUrlMale,
                                          ),
                                        );
                                      },
                                    ),
                          },
                        ),
                  ),
                  _MuscleFilterRail(
                    muscles: muscles,
                    selectedMuscle: _selectedMuscle,
                    onSelect: _onMuscleSelect,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: _newCount > 0 ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                disabledBackgroundColor: AppColors.buttonColor.withValues(
                  alpha: 0.35,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                _newCount == 0
                    ? 'Add Exercises'
                    : 'Add $_newCount Exercise${_newCount == 1 ? '' : 's'}',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets (visuals unchanged) ─────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Exercise Library',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search exercises',
          hintStyle: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}

class _ExerciseLibraryCard extends StatelessWidget {
  const _ExerciseLibraryCard({
    required this.name,
    required this.muscle,
    this.thumbnailUrl = '',
    required this.isSelected,
    this.alreadyAdded = false,
    required this.onTap,
    this.onPlay,
  });

  final String name;
  final String muscle;
  final String thumbnailUrl;
  final bool isSelected;

  /// Already in this day: dimmed with an "Added" mark, tap does nothing.
  final bool alreadyAdded;
  final VoidCallback onTap;

  /// Plays the exercise demo video; null leaves the thumbnail static.
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alreadyAdded ? null : onTap,
      child: Opacity(
        opacity: alreadyAdded ? 0.55 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: alreadyAdded
                ? Border.all(
                    color: const Color(0xFF2E8A4A).withValues(alpha: 0.5),
                  )
                : null,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onPlay,
                child: ExerciseThumbnail(size: 64, thumbnailUrl: thumbnailUrl),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (muscle.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        muscle,
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    if (alreadyAdded) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Added',
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: const Color(0xFF2E8A4A)),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (alreadyAdded)
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF2E8A4A),
                  size: 22.sp,
                )
              else
                Icon(
                  isSelected ? Icons.bookmark : Icons.bookmark_border_outlined,
                  color: isSelected
                      ? AppColors.buttonColor
                      : AppColors.textSecondary,
                  size: 22.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuscleFilterRail extends StatelessWidget {
  const _MuscleFilterRail({
    required this.muscles,
    required this.selectedMuscle,
    required this.onSelect,
  });

  final List<String> muscles;
  final String selectedMuscle;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76.w,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(4.w, 0, 8.w, 100.h),
        physics: const BouncingScrollPhysics(),
        itemCount: muscles.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final muscle = muscles[index];
          final isSelected = muscle == selectedMuscle;
          return GestureDetector(
            onTap: () => onSelect(muscle),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.buttonColor
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  muscle,
                  style: AppTextStyles.meduim11(context).copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
