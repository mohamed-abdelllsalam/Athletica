import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseLibraryPickerView extends StatefulWidget {
  const ExerciseLibraryPickerView({
    super.key,
    required this.alreadyAddedIds,
  });

  final Set<String> alreadyAddedIds;

  @override
  State<ExerciseLibraryPickerView> createState() =>
      _ExerciseLibraryPickerViewState();
}

class _ExerciseLibraryPickerViewState
    extends State<ExerciseLibraryPickerView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscle = 'All';
  String _query = '';
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.alreadyAddedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LibraryExercise> get _filtered {
    return ExerciseLibraryData.exercises.where((e) {
      final matchesMuscle =
          _selectedMuscle == 'All' || e.muscleGroup == _selectedMuscle;
      final matchesQuery =
          _query.isEmpty || e.name.toLowerCase().contains(_query.toLowerCase());
      return matchesMuscle && matchesQuery;
    }).toList();
  }

  int get _newCount =>
      _selectedIds.difference(widget.alreadyAddedIds).length;

  void _toggleExercise(LibraryExercise ex) {
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
    final newExercises = ExerciseLibraryData.exercises
        .where((e) =>
            _selectedIds.contains(e.id) &&
            !widget.alreadyAddedIds.contains(e.id))
        .toList();
    Navigator.pop(context, newExercises);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filtered;
    final muscles = ExerciseLibraryData.muscleGroups
        .where((m) => m != 'All')
        .toList();

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
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: exercises.isEmpty
                        ? Center(
                            child: Text(
                              'No exercises found',
                              style: AppTextStyles.medium14(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                                16.w, 0, 6.w, 100.h),
                            itemCount: exercises.length,
                            separatorBuilder: (_, _) =>
                                SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              final ex = exercises[index];
                              final isSelected =
                                  _selectedIds.contains(ex.id);
                              return _ExerciseLibraryCard(
                                exercise: ex,
                                isSelected: isSelected,
                                onTap: () => _toggleExercise(ex),
                              );
                            },
                          ),
                  ),
                  _MuscleFilterRail(
                    muscles: muscles,
                    selectedMuscle: _selectedMuscle,
                    onSelect: (m) => setState(() => _selectedMuscle = m),
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
                disabledBackgroundColor:
                    AppColors.buttonColor.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                _newCount == 0
                    ? 'Add Exercises'
                    : 'Add $_newCount Exercise${_newCount == 1 ? '' : 's'}',
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

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
            style: AppTextStyles.semiBold15(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

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
        style: AppTextStyles.medium14(context)
            .copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search exercises',
          hintStyle: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
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
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  final LibraryExercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            const ExerciseThumbnail(size: 64),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                exercise.name,
                style: AppTextStyles.medium14(context).copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              isSelected ? Icons.bookmark : Icons.bookmark_border_outlined,
              color: isSelected ? AppColors.buttonColor : AppColors.textSecondary,
              size: 22.sp,
            ),
          ],
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
