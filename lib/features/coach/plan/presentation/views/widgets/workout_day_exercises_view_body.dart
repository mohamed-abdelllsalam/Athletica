import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/exercise_library_picker_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutDayExercisesViewBody extends StatefulWidget {
  const WorkoutDayExercisesViewBody({super.key, required this.day});

  final ProgramDay day;

  @override
  State<WorkoutDayExercisesViewBody> createState() =>
      _WorkoutDayExercisesViewBodyState();
}

class _WorkoutDayExercisesViewBodyState
    extends State<WorkoutDayExercisesViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<ProgramExercise> _exercises;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _exercises = List.from(widget.day.exercises);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<ProgramExercise> get _filtered {
    if (_query.isEmpty) return _exercises;
    return _exercises
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void _removeExercise(ProgramExercise exercise) {
    setState(() => _exercises.removeWhere((e) => e.id == exercise.id));
  }

  Future<void> _clearAllExercises() async {
    if (_exercises.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Clear All Exercises',
          style: AppTextStyles.semiBold14(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remove all exercises from this day?',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _exercises.clear();
        _searchController.clear();
        _query = '';
      });
    }
  }

  void _showEditDialog(ProgramExercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _EditExerciseSheet(exercise: exercise),
    );
  }

  Future<void> _openExercisePicker() async {
    final result = await Navigator.push<List<LibraryExercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseLibraryPickerView(
          alreadyAddedIds: _exercises.map((e) => e.id).toSet(),
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        for (final lib in result) {
          _exercises.add(ProgramExercise(id: lib.id, name: lib.name));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Day ${widget.day.dayNumber}',
          style: AppTextStyles.medium14(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          widget.day.name,
          style: AppTextStyles.bold24(context).copyWith(
            color: AppColors.textPrimary,
            fontSize: 22.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: AppColors.textSecondary, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                '${_exercises.length} Exercises',
                style: AppTextStyles.meduim12(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.timer_outlined,
                  color: AppColors.textSecondary, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                '• ${widget.day.durationMinutes} min',
                style: AppTextStyles.meduim12(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.buttonColor,
            indicatorWeight: 2,
            labelStyle: AppTextStyles.semiBold14(context),
            unselectedLabelStyle: AppTextStyles.medium14(context),
            labelColor: AppColors.buttonColor,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [Tab(text: 'Exercises'), Tab(text: 'Note')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ExercisesTab(
                searchController: _searchController,
                exercises: _filtered,
                allExercises: _exercises,
                query: _query,
                onQueryChanged: (v) => setState(() => _query = v),
                onEdit: _showEditDialog,
                onDelete: _removeExercise,
                onSave: () => Navigator.pop(context),
                onOpenPicker: _openExercisePicker,
                onClearAll: _clearAllExercises,
              ),
              _NoteTab(controller: _noteController),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Exercises tab ─────────────────────────────────────────────────────────────

class _ExercisesTab extends StatelessWidget {
  const _ExercisesTab({
    required this.searchController,
    required this.exercises,
    required this.allExercises,
    required this.query,
    required this.onQueryChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onSave,
    required this.onOpenPicker,
    required this.onClearAll,
  });

  final TextEditingController searchController;
  final List<ProgramExercise> exercises;
  final List<ProgramExercise> allExercises;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ProgramExercise> onEdit;
  final ValueChanged<ProgramExercise> onDelete;
  final VoidCallback onSave;
  final VoidCallback onOpenPicker;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onQueryChanged,
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
              // Trash icon — clears all exercises after confirm
              GestureDetector(
                onTap: onClearAll,
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.delete_sweep_outlined,
                    color: allExercises.isEmpty
                        ? AppColors.textTertiary
                        : AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
            itemCount: exercises.isEmpty && query.isNotEmpty
                ? 1
                : exercises.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              // Empty search state
              if (exercises.isEmpty && query.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Text(
                      'No exercises found',
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              // + Add Exercise tile (last item)
              if (index == exercises.length) {
                return _AddExerciseTile(onTap: onOpenPicker);
              }
              final exercise = exercises[index];
              return _ExerciseCard(
                exercise: exercise,
                onEdit: () => onEdit(exercise),
                onDelete: () => onDelete(exercise),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Save Changes',
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Add Exercise dashed tile ──────────────────────────────────────────────────

class _AddExerciseTile extends StatelessWidget {
  const _AddExerciseTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.buttonColor.withValues(alpha: 0.5),
            width: 1.5,
            // Dashed via custom painter below
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                color: AppColors.buttonColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Add Exercise',
              style: AppTextStyles.semiBold14(context).copyWith(
                color: AppColors.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercise card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  final ProgramExercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          GestureDetector(
            onTap: onEdit,
            child: Icon(Icons.edit_outlined,
                color: AppColors.textSecondary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
          ),
        ],
      ),
    );
  }
}

// ── Note tab ──────────────────────────────────────────────────────────────────

class _NoteTab extends StatelessWidget {
  const _NoteTab({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write Note',
            style: AppTextStyles.semiBold14(context).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTextStyles.medium14(context).copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Type Your Note !',
                  hintStyle: AppTextStyles.medium14(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Submit',
                style: AppTextStyles.medium14(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit exercise sheet ───────────────────────────────────────────────────────

class _EditExerciseSheet extends StatefulWidget {
  const _EditExerciseSheet({required this.exercise});

  final ProgramExercise exercise;

  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _restController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _setsController.dispose();
    _restController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              widget.exercise.name,
              style: AppTextStyles.semiBold14(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _FieldWithLabel(
                    label: 'Reps',
                    icon: Icons.list_alt_outlined,
                    controller: _repsController,
                    keyboardType: TextInputType.text,
                    hint: '8-10',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _FieldWithLabel(
                    label: 'Sets',
                    icon: Icons.repeat,
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    hint: '3',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _FieldWithLabel(
                    label: 'Rest (s)',
                    icon: Icons.timer_outlined,
                    controller: _restController,
                    keyboardType: TextInputType.number,
                    hint: '60',
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              'Note',
              style: AppTextStyles.semiBold14(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextField(
                controller: _noteController,
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Optional note…',
                  hintStyle: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Save',
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldWithLabel extends StatelessWidget {
  const _FieldWithLabel({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppTextStyles.meduim12(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.medium14(context)
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }
}
