import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/exercise_library_picker_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_day_exercises_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutDayExercisesViewBody extends StatefulWidget {
  const WorkoutDayExercisesViewBody({
    super.key,
    required this.day,
    this.isCreateMode = false,
  });

  final ProgramDay day;
  final bool isCreateMode;

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
  late TextEditingController _nameController;
  bool _nameHasError = false;
  String _query = '';

  // Baseline snapshot used to detect unsaved edits.
  late String _initialName;
  late String _initialNote;
  late String _initialExercisesSignature;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _exercises = List.from(widget.day.exercises);
    _nameController = TextEditingController(text: widget.day.name);
    _noteController.text = widget.day.note;
    _initialName = widget.day.name.trim();
    _initialNote = widget.day.note.trim();
    _initialExercisesSignature = _exercisesSignature;
    _nameController.addListener(() {
      if (_nameHasError && _nameController.text.trim().isNotEmpty) {
        setState(() => _nameHasError = false);
      }
    });
  }

  String get _exercisesSignature => _exercises.map((e) => e.id).join('|');

  bool get _isDirty =>
      _nameController.text.trim() != _initialName ||
      _noteController.text.trim() != _initialNote ||
      _exercisesSignature != _initialExercisesSignature;

  /// Leaving flow for unsaved edits: Save and exit, or Discard.
  Future<void> _exitWithResolution() async {
    FocusScope.of(context).unfocus();
    if (!_isDirty) {
      Navigator.pop(context);
      return;
    }
    final action = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Unsaved changes',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Do you want to save your changes before leaving?',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'saveExit'),
            child: Text(
              'Save and exit',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.primaryBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(
              'Discard',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'saveExit':
        _saveAndExit();
      case 'discard':
        Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _noteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    if (widget.isCreateMode && _nameController.text.trim().isEmpty) {
      setState(() => _nameHasError = true);
      return;
    }
    Navigator.pop(context, (
      exercises: List<ProgramExercise>.from(_exercises),
      name: widget.isCreateMode ? _nameController.text.trim() : widget.day.name,
      note: _noteController.text.trim(),
      deleted: false,
    ));
  }

  Future<void> _confirmDeleteDay() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete day?',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remove "${_nameController.text.trim()}" and its exercises?',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    Navigator.pop(context, (
      exercises: <ProgramExercise>[],
      name: '',
      note: '',
      deleted: true,
    ));
  }

  List<ProgramExercise> get _filtered {
    if (_query.isEmpty) return _exercises;
    final q = _query.toLowerCase();
    // Bilingual label covers both languages in one check.
    return _exercises
        .where((e) => e.displayName.toLowerCase().contains(q))
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
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remove all exercises from this day?',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.redAccent),
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
          _exercises.add(
            ProgramExercise(
              id: lib.id,
              name: lib.name,
              nameEn: lib.nameEn,
              nameAr: lib.nameAr,
              thumbnailUrl: lib.thumbnailUrl,
              videoUrlMale: lib.videoUrlMale,
              videoUrlFemale: lib.videoUrlFemale,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _exitWithResolution();
      },
      child: Column(
        children: [
          SizedBox(height: 20.h),
          WorkoutDayHeader(
            day: widget.day,
            isCreateMode: widget.isCreateMode,
            nameController: _nameController,
            nameHasError: _nameHasError,
            exerciseCount: _exercises.length,
            onExit: _exitWithResolution,
            onDelete: _confirmDeleteDay,
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
              tabs: const [
                Tab(text: 'Exercises'),
                Tab(text: 'Note'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                WorkoutDayExercisesTab(
                  searchController: _searchController,
                  exercises: _filtered,
                  allExercises: _exercises,
                  query: _query,
                  onQueryChanged: (v) => setState(() => _query = v),
                  onDelete: _removeExercise,
                  onSave: _saveAndExit,
                  onOpenPicker: _openExercisePicker,
                  onClearAll: _clearAllExercises,
                ),
                WorkoutDayNoteTab(
                  controller: _noteController,
                  onSubmit: _saveAndExit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
