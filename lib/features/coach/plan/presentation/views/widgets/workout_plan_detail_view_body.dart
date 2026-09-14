import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_state.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/customize_workout_assignment_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/exercise_library_picker_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_day_exercises_view.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_state.dart';
import 'package:athletica/features/workout/presentation/views/workout_plan_detail_screen.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_state.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Template detail — `GET /workout/templates/:id` + day/exercise CRUD +
/// assign. Visuals preserved; all mutations hit the API and replace
/// local state with the returned full template.
class WorkoutPlanDetailViewBody extends StatefulWidget {
  const WorkoutPlanDetailViewBody({
    super.key,
    required this.program,
    this.isCreateMode = false,
  });

  final WorkoutProgram program;
  final bool isCreateMode;

  @override
  State<WorkoutPlanDetailViewBody> createState() =>
      _WorkoutPlanDetailViewBodyState();
}

class _WorkoutPlanDetailViewBodyState extends State<WorkoutPlanDetailViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  late List<ProgramDay> _days;
  bool _nameHasError = false;
  bool _descriptionHasError = false;
  late String _selectedCategory;

  static const List<String> _createCategories = [
    'Strength',
    'Fat loss',
    'Boxing',
    'Mobility',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.program.category.isEmpty
        ? 'Custom'
        : widget.program.category;
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.program.name);
    _nameController.addListener(() {
      if (_nameHasError && _nameController.text.trim().isNotEmpty) {
        setState(() => _nameHasError = false);
      }
    });
    _descriptionController = TextEditingController(
      text: widget.program.description,
    );
    _descriptionController.addListener(() {
      if (_descriptionHasError &&
          _descriptionController.text.trim().isNotEmpty) {
        setState(() => _descriptionHasError = false);
      }
    });
    _noteController = TextEditingController();
    _days = List.from(widget.program.days);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _iconForCategory(String category) => switch (category) {
    'Strength' => 'assets/images/plan/muscle_gain_icon.svg',
    'Fat loss' => 'assets/images/plan/fatloss_icon.svg',
    'Boxing' => 'assets/images/plan/boxing_icon.svg',
    'Mobility' => 'assets/images/plan/recover_icon.svg',
    _ => 'assets/images/plan/upper_body_icon.svg',
  };

  String get _currentIconAsset => _iconForCategory(_selectedCategory);

  WorkoutProgram _buildPlan() {
    return WorkoutProgram(
      id: widget.program.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      splitType: _days.isEmpty ? '' : '${_days.length} Days Split',
      updatedAgo: 'Just created',
      clientCount: 0,
      description: _descriptionController.text.trim(),
      iconAsset: _currentIconAsset,
      days: List.from(_days),
    );
  }

  void _trySavePlan() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    var hasError = false;
    if (name.isEmpty) {
      setState(() => _nameHasError = true);
      hasError = true;
    }
    if (description.isEmpty) {
      setState(() => _descriptionHasError = true);
      hasError = true;
    }
    if (hasError) return;
    Navigator.pop(context, _buildPlan());
  }

  Future<void> _exitWithResolution() async {
    FocusScope.of(context).unfocus();
    final hasContent =
        _nameController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _days.isNotEmpty;
    if (!hasContent) {
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
        _trySavePlan();
      case 'discard':
        Navigator.pop(context);
    }
  }

  void _renumberDays() {
    for (var i = 0; i < _days.length; i++) {
      final d = _days[i];
      if (d.dayNumber != i + 1) {
        _days[i] = d.copyWith(dayNumber: i + 1);
      }
    }
  }

  void _addDayLocal() {
    setState(() {
      final nextNumber = _days.length + 1;
      _days.add(
        ProgramDay(
          dayNumber: nextNumber,
          name: 'Day $nextNumber',
          durationMinutes: 60,
          exercises: const [],
        ),
      );
    });
  }

  void _toggleRestLocal(int index) {
    if (index < 0 || index >= _days.length) return;
    setState(() {
      final d = _days[index];
      _days[index] = d.copyWith(isRest: !d.isRest);
    });
  }

  void _reorderLocal(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final moved = _days.removeAt(oldIndex);
      _days.insert(newIndex, moved);
      _renumberDays();
    });
  }

  Future<void> _handleDayTapByIndex(int index) async {
    if (index < 0 || index >= _days.length) return;
    final day = _days[index];
    final result = await Navigator.push<WorkoutDayEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDayExercisesView(day: day, isCreateMode: true),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (index >= _days.length) return;
      if (result.deleted) {
        _days.removeAt(index);
        _renumberDays();
        return;
      }
      _days[index] = _days[index].copyWith(
        name: result.name,
        exercises: List.from(result.exercises),
        note: result.note,
      );
    });
  }

  ProgramDay _toProgramDay(TemplateDayEntry d) => ProgramDay(
    dayNumber: d.dayNumber,
    name: d.title,
    durationMinutes: 60,
    isRest: d.isRest,
    note: d.note,
    exerciseCount: d.exerciseCount,
    exercises: d.exercises.map((e) {
      final ex = e.exercise;
      return ProgramExercise(
        id: e.exerciseId,
        name: (ex?.nameEn.isNotEmpty ?? false) ? ex!.nameEn : e.exerciseId,
        nameEn: ex?.nameEn,
        nameAr: ex?.nameAr,
        thumbnailUrl: pickGenderedUrl(
          maleUrl: ex?.thumbnailUrlMale ?? '',
          femaleUrl: ex?.thumbnailUrlFemale ?? '',
        ),
        videoUrlMale: ex?.videoUrlMale ?? '',
        videoUrlFemale: ex?.videoUrlFemale ?? '',
      );
    }).toList(),
  );

  Future<void> _addDay() async {
    final current = context.read<WorkoutTemplateDetailCubit>().state;
    if (current is! WorkoutTemplateDetailLoaded) return;
    final title = await showDialog<String>(
      context: context,
      builder: (_) => _AddDayDialog(
        initialTitle: 'Day ${current.template.days.length + 1}',
      ),
    );
    if (title == null || title.isEmpty || !mounted) return;
    final ok = await context.read<WorkoutTemplateDetailCubit>().addDay(title);
    if (!mounted) return;
    if (!ok) _showMutationError();
  }

  Future<void> _removeDay(TemplateDayEntry day) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete day?',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remove "${day.title}" and its exercises?',
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
    if (confirm != true || !mounted) return;
    final ok = await context.read<WorkoutTemplateDetailCubit>().removeDay(
      day.id,
    );
    if (!mounted) return;
    if (!ok) _showMutationError();
  }

  Future<void> _toggleRest(TemplateDayEntry day) async {
    final ok = await context.read<WorkoutTemplateDetailCubit>().editDay(
      day.id,
      isRest: !day.isRest,
    );
    if (!mounted) return;
    if (!ok) _showMutationError();
  }

  Future<void> _renameSavedDay(TemplateDayEntry day) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _AddDayDialog(
        initialTitle: day.title,
        dialogTitle: 'Rename Day',
        confirmLabel: 'Save',
      ),
    );
    if (result == null || result.isEmpty || !mounted) return;
    final ok = await context.read<WorkoutTemplateDetailCubit>().editDay(
      day.id,
      title: result,
    );
    if (!mounted) return;
    if (!ok) _showMutationError();
  }

  Future<void> _reorderSavedDays(
    List<TemplateDayEntry> days,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final ordered = [...days];
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);
    final ok = await context.read<WorkoutTemplateDetailCubit>().reorderDays(
      ordered.map((d) => d.id).toList(),
    );
    if (!mounted) return;
    if (!ok) _showMutationError();
  }

  Future<void> _openDay(TemplateDayEntry day) async {
    final result = await Navigator.push<WorkoutDayEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDayExercisesView(
          day: _toProgramDay(day),
          isCreateMode: true,
        ),
      ),
    );
    if (result == null || !mounted) return;
    final cubit = context.read<WorkoutTemplateDetailCubit>();
    if (result.deleted) {
      final ok = await cubit.removeDay(day.id);
      if (!mounted) return;
      if (!ok) _showMutationError();
      return;
    }
    if (result.name.isNotEmpty && result.name != day.title) {
      final ok = await cubit.editDay(day.id, title: result.name);
      if (!mounted) return;
      if (!ok) {
        _showMutationError();
        return;
      }
    }
    if (result.note != day.note) {
      final ok = await cubit.editDay(day.id, note: result.note);
      if (!mounted) return;
      if (!ok) {
        _showMutationError();
        return;
      }
    }
    await _reconcileExercises(day, result.exercises);
  }

  /// Reconciles the locally edited exercise list with the API:
  /// adds picked exercises (appended with `exercise_order`), removes
  /// deleted ones. Template exercises carry no sets/reps.
  Future<void> _reconcileExercises(
    TemplateDayEntry day,
    List<ProgramExercise> updated,
  ) async {
    final cubit = context.read<WorkoutTemplateDetailCubit>();
    final currentIds = day.exercises.map((e) => e.exerciseId).toSet();
    final updatedIds = updated.map((e) => e.id).toSet();

    final toRemove = day.exercises.where(
      (e) => !updatedIds.contains(e.exerciseId),
    );
    for (final ex in toRemove) {
      final ok = await cubit.removeExercise(day.id, ex.id);
      if (!mounted) return;
      if (!ok) {
        _showMutationError();
        return;
      }
    }

    var state = cubit.state;
    if (state is! WorkoutTemplateDetailLoaded) return;
    var liveDay = state.template.days.firstWhere(
      (d) => d.id == day.id,
      orElse: () => day,
    );
    for (final prog in updated) {
      if (currentIds.contains(prog.id)) continue;
      final ok = await cubit.addExercise(
        liveDay.id,
        exerciseId: prog.id,
        exerciseOrder: liveDay.exercises.length + 1,
      );
      if (!mounted) return;
      if (!ok) {
        _showMutationError();
        return;
      }
      state = cubit.state;
      if (state is WorkoutTemplateDetailLoaded) {
        liveDay = state.template.days.firstWhere(
          (d) => d.id == day.id,
          orElse: () => liveDay,
        );
      }
    }
  }

  Future<void> _pickAndAddExercises(TemplateDayEntry day) async {
    final current = context.read<WorkoutTemplateDetailCubit>().state;
    if (current is! WorkoutTemplateDetailLoaded) return;
    final liveDay = current.template.days.firstWhere(
      (d) => d.id == day.id,
      orElse: () => day,
    );
    final result = await Navigator.push<List<LibraryExercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseLibraryPickerView(
          alreadyAddedIds: liveDay.exercises.map((e) => e.exerciseId).toSet(),
        ),
      ),
    );
    if (result == null || result.isEmpty || !mounted) return;
    final cubit = context.read<WorkoutTemplateDetailCubit>();
    for (final lib in result) {
      final s = cubit.state;
      final count = s is WorkoutTemplateDetailLoaded
          ? s.template.days
                .firstWhere((d) => d.id == day.id, orElse: () => liveDay)
                .exercises
                .length
          : liveDay.exercises.length;
      final ok = await cubit.addExercise(
        day.id,
        exerciseId: lib.id,
        exerciseOrder: count + 1,
      );
      if (!mounted) return;
      if (!ok) {
        _showMutationError();
        return;
      }
    }
  }

  void _showMutationError() {
    final err = context.read<WorkoutTemplateDetailCubit>().lastError;
    if (err == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }

  /// Leaving flow for saved templates: auto-saves a dirty name/description
  /// (the inline fields have no explicit save button), then pops with
  /// `hasChanges` so the list refreshes — like nutrition's detail.
  Future<void> _exitDetail() async {
    final cubit = context.read<WorkoutTemplateDetailCubit>();
    final state = cubit.state;
    if (state is WorkoutTemplateDetailLoaded) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final nameDirty = name.isNotEmpty && name != state.template.title;
      final descriptionDirty = description != state.template.description;
      if (nameDirty || descriptionDirty) {
        FocusScope.of(context).unfocus();
        final ok = await cubit.rename(
          title: nameDirty ? name : null,
          description: descriptionDirty ? description : null,
        );
        if (!mounted) return;
        if (!ok) {
          _showMutationError();
          return;
        }
      }
    }
    if (!mounted) return;
    Navigator.pop(context, cubit.hasChanges);
  }

  Widget _buildCreateContent(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _exitWithResolution();
      },
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GestureDetector(
              onTap: _exitWithResolution,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.arrow_back_ios_new),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SvgPicture.asset(
                    _currentIconAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Name',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 4.h),
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: AppTextStyles.bold24(context).copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 20.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Plan name',
                          hintStyle: AppTextStyles.bold24(context).copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 20.sp,
                          ),
                          errorText: _nameHasError ? 'Required' : null,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.textSecondary,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _days.isEmpty
                                ? 'No days yet'
                                : '${_days.length} Days Split',
                            style: AppTextStyles.meduim12(
                              context,
                            ).copyWith(color: AppColors.textSecondary),
                          ),
                          SizedBox(width: 8.w),
                          _CreateCategorySelector(
                            selected: _selectedCategory,
                            categories: _createCategories,
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _trySavePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Save Plan',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
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
                Tab(text: 'Overview'),
                Tab(text: 'Note'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CreateOverviewTab(
                  descriptionController: _descriptionController,
                  descriptionHasError: _descriptionHasError,
                  days: _days,
                  onAddDay: _addDayLocal,
                  onOpenDay: _handleDayTapByIndex,
                  onToggleRest: _toggleRestLocal,
                  onReorder: _reorderLocal,
                ),
                _NoteTab(controller: _noteController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCreateMode) {
      return UnfocusOnTap(child: _buildCreateContent(context));
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _exitDetail();
      },
      child:
          BlocConsumer<WorkoutTemplateDetailCubit, WorkoutTemplateDetailState>(
            // Server is the source of truth: sync the title/description fields
            // when a new template arrives. This runs outside build() so typing
            // and cursor position are never clobbered by rebuilds.
            listener: (context, state) {
              if (state is! WorkoutTemplateDetailLoaded) return;
              if (_nameController.text != state.template.title) {
                _nameController.text = state.template.title;
              }
              if (_descriptionController.text != state.template.description) {
                _descriptionController.text = state.template.description;
              }
            },
            builder: (context, state) => switch (state) {
              WorkoutTemplateDetailInitial() ||
              WorkoutTemplateDetailLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              WorkoutTemplateDetailError(:final message) => Center(
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
                        onPressed: () => context
                            .read<WorkoutTemplateDetailCubit>()
                            .load(widget.program.id),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              WorkoutTemplateDetailLoaded(:final template, :final mutating) =>
                _DetailContent(
                  template: template,
                  mutating: mutating,
                  tabController: _tabController,
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  noteController: _noteController,
                  program: widget.program,
                  onAddDay: _addDay,
                  onRemoveDay: _removeDay,
                  onToggleRest: _toggleRest,
                  onRenameDay: _renameSavedDay,
                  onReorderDays: _reorderSavedDays,
                  onOpenDay: _openDay,
                  onAddExercises: _pickAndAddExercises,
                  onShowAssign: () => _showAssignSheet(context, template),
                  onDeleteTemplate: () =>
                      _confirmDeleteTemplate(context, template),
                  onExit: _exitDetail,
                  onSaveTitle: () async {
                    final ok = await context
                        .read<WorkoutTemplateDetailCubit>()
                        .rename(
                          title: _nameController.text.trim().isEmpty
                              ? null
                              : _nameController.text.trim(),
                          description:
                              _descriptionController.text.trim().isEmpty
                              ? null
                              : _descriptionController.text.trim(),
                        );
                    if (!context.mounted) return;
                    if (!ok) _showMutationError();
                  },
                ),
            },
          ),
    );
  }

  /// Deletes the whole template after confirmation, like nutrition's
  /// delete-template icon. Pops with `true` so the list refreshes.
  Future<void> _confirmDeleteTemplate(
    BuildContext context,
    WorkoutTemplateEntry template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete template?',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will permanently delete "${template.title}" and cannot be undone.',
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<WorkoutTemplatesCubit>().remove(template.id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      return;
    }
    final state = context.read<WorkoutTemplatesCubit>().state;
    final message = state is WorkoutTemplatesLoaded
        ? state.mutationError
        : null;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message ?? 'Delete failed')));
  }

  void _showAssignSheet(BuildContext context, WorkoutTemplateEntry template) async {
    final selection =
        await showModalBottomSheet<({String relationId, String clientName})>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CoachClientsCubit>()),
          BlocProvider.value(value: context.read<WorkoutPlansCubit>()),
        ],
        child: _AssignToClientSheet(template: template),
      ),
    );
    if (selection == null || !context.mounted) return;
    final assignedPlanId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomizeWorkoutAssignmentView(
          template: template,
          coachClientId: selection.relationId,
          clientName: selection.clientName,
        ),
      ),
    );
    if (!context.mounted ||
        assignedPlanId == null ||
        assignedPlanId.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout assigned successfully')),
    );
  }
}

/// Owns its controller so it is disposed with the dialog route itself —
/// never dispose a dialog's controller right after `await showDialog`,
/// the exit animation still paints its TextField.
class _AddDayDialog extends StatefulWidget {
  const _AddDayDialog({
    required this.initialTitle,
    this.dialogTitle = 'Add Day',
    this.confirmLabel = 'Add',
  });

  final String initialTitle;
  final String dialogTitle;
  final String confirmLabel;

  @override
  State<_AddDayDialog> createState() => _AddDayDialogState();
}

class _AddDayDialogState extends State<_AddDayDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        widget.dialogTitle,
        style: AppTextStyles.semiBold14(
          context,
        ).copyWith(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Day title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.template,
    required this.mutating,
    required this.tabController,
    required this.nameController,
    required this.descriptionController,
    required this.noteController,
    required this.program,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onToggleRest,
    required this.onRenameDay,
    required this.onReorderDays,
    required this.onOpenDay,
    required this.onAddExercises,
    required this.onShowAssign,
    required this.onDeleteTemplate,
    required this.onExit,
    required this.onSaveTitle,
  });

  final WorkoutTemplateEntry template;
  final bool mutating;
  final TabController tabController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController noteController;
  final WorkoutProgram program;
  final VoidCallback onAddDay;
  final ValueChanged<TemplateDayEntry> onRemoveDay;
  final ValueChanged<TemplateDayEntry> onToggleRest;
  final ValueChanged<TemplateDayEntry> onRenameDay;
  final void Function(List<TemplateDayEntry> days, int oldIndex, int newIndex)
  onReorderDays;
  final ValueChanged<TemplateDayEntry> onOpenDay;
  final ValueChanged<TemplateDayEntry> onAddExercises;
  final VoidCallback onShowAssign;
  final VoidCallback onDeleteTemplate;
  final VoidCallback onExit;
  final VoidCallback onSaveTitle;

  @override
  Widget build(BuildContext context) {
    // Title/description are synced from the server via the BlocListener
    // above — never assign controller.text here.
    return Column(
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: onExit,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: mutating ? null : onDeleteTemplate,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: const Color(0xFFFF5252),
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: SvgPicture.asset(program.iconAsset, fit: BoxFit.contain),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Name',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: nameController,
                      onSubmitted: (_) => onSaveTitle(),
                      style: AppTextStyles.bold24(
                        context,
                      ).copyWith(color: AppColors.textPrimary, fontSize: 20.sp),
                      decoration: InputDecoration(
                        hintText: 'Plan name',
                        hintStyle: AppTextStyles.bold24(context).copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 20.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textSecondary,
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${template.dayCount} Days Split',
                          style: AppTextStyles.meduim12(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                        SizedBox(width: 8.w),
                        const _CategoryBadge(category: 'Custom'),
                        if (mutating) ...[
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 14.r,
                            height: 14.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: mutating ? null : onShowAssign,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 18.sp,
              ),
              label: Text(
                'Assign to client',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: TabBar(
            controller: tabController,
            indicatorColor: AppColors.buttonColor,
            indicatorWeight: 2,
            labelStyle: AppTextStyles.semiBold14(context),
            unselectedLabelStyle: AppTextStyles.medium14(context),
            labelColor: AppColors.buttonColor,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Note'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _OverviewTab(
                descriptionController: descriptionController,
                template: template,
                onAddDay: onAddDay,
                onRemoveDay: onRemoveDay,
                onToggleRest: onToggleRest,
                onRenameDay: onRenameDay,
                onReorderDays: onReorderDays,
                onNavigateDay: onOpenDay,
                onAddExercises: onAddExercises,
                onSaveTitle: onSaveTitle,
              ),
              _NoteTab(controller: noteController),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.descriptionController,
    required this.template,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onToggleRest,
    required this.onRenameDay,
    required this.onReorderDays,
    required this.onNavigateDay,
    required this.onAddExercises,
    required this.onSaveTitle,
  });

  final TextEditingController descriptionController;
  final WorkoutTemplateEntry template;
  final VoidCallback onAddDay;
  final ValueChanged<TemplateDayEntry> onRemoveDay;
  final ValueChanged<TemplateDayEntry> onToggleRest;
  final ValueChanged<TemplateDayEntry> onRenameDay;
  final void Function(List<TemplateDayEntry> days, int oldIndex, int newIndex)
  onReorderDays;
  final ValueChanged<TemplateDayEntry> onNavigateDay;
  final ValueChanged<TemplateDayEntry> onAddExercises;
  final VoidCallback onSaveTitle;

  List<_DayMenuAction> _menuFor(TemplateDayEntry day) => [
    if (!day.isRest)
      const _DayMenuAction(
        value: 'add',
        label: 'Add exercises',
        icon: Icons.add,
      ),
    _DayMenuAction(
      value: 'rest',
      label: day.isRest ? 'Remove rest day' : 'Make as a rest day',
      icon: day.isRest ? Icons.bedtime : Icons.bedtime_outlined,
    ),
    const _DayMenuAction(
      value: 'rename',
      label: 'Rename',
      icon: Icons.edit_outlined,
    ),
    const _DayMenuAction(
      value: 'delete',
      label: 'Delete',
      icon: Icons.delete_outline,
      danger: true,
    ),
  ];

  void _onMenu(TemplateDayEntry day, String value) {
    switch (value) {
      case 'add':
        onAddExercises(day);
      case 'rest':
        onToggleRest(day);
      case 'rename':
        onRenameDay(day);
      case 'delete':
        onRemoveDay(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Description is synced from the server via the BlocListener above.
    final days = [...template.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        Text(
          'Program Overview',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: descriptionController,
          maxLines: null,
          onSubmitted: (_) => onSaveTitle(),
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: 'Add a program description…',
            hintStyle: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textTertiary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Program Days',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: onAddDay,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.buttonColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.buttonColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add Days',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.buttonColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (days.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No days yet — tap + Add Days',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) =>
                onReorderDays(days, oldIndex, newIndex),
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Material(
                color: Colors.transparent,
                elevation: 6 * animation.value,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(14.r),
                child: child,
              ),
              child: child,
            ),
            children: [
              for (var i = 0; i < days.length; i++)
                Container(
                  key: ValueKey(days[i].id),
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            Icons.drag_handle,
                            color: AppColors.textSecondary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _DayCard(
                          dayLabel: 'D${days[i].dayNumber}',
                          title: days[i].title,
                          subtitle: days[i].isRest
                              ? 'Rest day'
                              : '${days[i].exerciseCount} Exercises',
                          isRest: days[i].isRest,
                          color: _kDayColors[i % _kDayColors.length],
                          onNavigate: () => onNavigateDay(days[i]),
                          actions: _menuFor(days[i]),
                          onMenuSelected: (v) => _onMenu(days[i], v),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ── Shared day colors + day card (saved + create share one design) ────────────

const List<Color> _kDayColors = [
  Color(0xFF3D2E8A),
  Color(0xFF2E5EA8),
  Color(0xFF2E8A4A),
  Color(0xFFB5541C),
  Color(0xFF6A2E8A),
  Color(0xFF1B6E6A),
];

class _DayMenuAction {
  const _DayMenuAction({
    required this.value,
    required this.label,
    required this.icon,
    this.danger = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool danger;
}

/// One day row design for both modes: full-row tap opens the day editor,
/// rest days get dimmed styling, everything else lives in the ⋮ menu.
class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayLabel,
    required this.title,
    required this.subtitle,
    required this.isRest,
    required this.color,
    required this.onNavigate,
    required this.actions,
    required this.onMenuSelected,
  });

  final String dayLabel;
  final String title;
  final String subtitle;
  final bool isRest;
  final Color color;
  final VoidCallback onNavigate;
  final List<_DayMenuAction> actions;
  final ValueChanged<String> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final iconColor = isRest ? AppColors.textTertiary : color;
    return GestureDetector(
      onTap: onNavigate,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isRest
              ? AppColors.cardBackground.withValues(alpha: 0.6)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: isRest
              ? Border.all(color: AppColors.textTertiary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: isRest
                    ? Icon(Icons.bedtime, color: Colors.white, size: 20.sp)
                    : Text(
                        dayLabel,
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
              padding: EdgeInsets.zero,
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: onMenuSelected,
              itemBuilder: (_) => [
                for (final action in actions)
                  PopupMenuItem(
                    value: action.value,
                    child: Row(
                      children: [
                        Icon(
                          action.icon,
                          size: 18,
                          color: action.danger
                              ? Colors.redAccent
                              : action.value == 'add'
                              ? AppColors.buttonColor
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          action.label,
                          style: TextStyle(
                            color: action.danger ? Colors.redAccent : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create-mode overview tab (local days, like nutrition Add Meal) ──────────

class _CreateOverviewTab extends StatelessWidget {
  const _CreateOverviewTab({
    required this.descriptionController,
    required this.descriptionHasError,
    required this.days,
    required this.onAddDay,
    required this.onOpenDay,
    required this.onToggleRest,
    required this.onReorder,
  });

  final TextEditingController descriptionController;
  final bool descriptionHasError;
  final List<ProgramDay> days;
  final VoidCallback onAddDay;
  final ValueChanged<int> onOpenDay;
  final ValueChanged<int> onToggleRest;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        Text(
          'Program Overview',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: descriptionController,
          maxLines: null,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: 'Add a program description…',
            hintStyle: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textTertiary),
            errorText: descriptionHasError ? 'Required' : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Program Days',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: onAddDay,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.buttonColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.buttonColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add Days',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.buttonColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (days.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No days yet — tap + Add Days',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            onReorder: onReorder,
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Material(
                color: Colors.transparent,
                elevation: 6 * animation.value,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(14.r),
                child: child,
              ),
              child: child,
            ),
            children: [
              for (var i = 0; i < days.length; i++)
                Container(
                  key: ValueKey(days[i]),
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            Icons.drag_handle,
                            color: AppColors.textSecondary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _CreateDayRow(
                          day: days[i],
                          color: _kDayColors[i % _kDayColors.length],
                          onNavigate: () => onOpenDay(i),
                          onToggleRest: () => onToggleRest(i),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _CreateDayRow extends StatelessWidget {
  const _CreateDayRow({
    required this.day,
    required this.color,
    required this.onNavigate,
    required this.onToggleRest,
  });

  final ProgramDay day;
  final Color color;
  final VoidCallback onNavigate;
  final VoidCallback onToggleRest;

  @override
  Widget build(BuildContext context) {
    return _DayCard(
      dayLabel: 'D${day.dayNumber}',
      title: day.name,
      subtitle: day.isRest ? 'Rest day' : '${day.exerciseCount} Exercises',
      isRest: day.isRest,
      color: color,
      onNavigate: onNavigate,
      actions: [
        _DayMenuAction(
          value: 'rest',
          label: day.isRest ? 'Remove rest day' : 'Make as a rest day',
          icon: day.isRest ? Icons.bedtime : Icons.bedtime_outlined,
        ),
      ],
      onMenuSelected: (_) => onToggleRest(),
    );
  }
}

// ── Category selector pill (create mode) ─────────────────────────────────────

class _CreateCategorySelector extends StatelessWidget {
  const _CreateCategorySelector({
    required this.selected,
    required this.categories,
    required this.onChanged,
  });

  final String selected;
  final List<String> categories;
  final ValueChanged<String> onChanged;

  Color get _color => switch (selected) {
    'Strength' => const Color(0xFF7B4FE8),
    'Fat loss' => const Color(0xFF7B4FE8),
    'Boxing' => const Color(0xFFD4752A),
    'Mobility' => const Color(0xFF2E6DB4),
    'Vegan' => const Color(0xFF2E8A4A),
    _ => const Color(0xFFB22A4A),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pick = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          builder: (_) => _CreateCategoryPickerSheet(
            categories: categories,
            selected: selected,
          ),
        );
        if (pick != null) onChanged(pick);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: AppTextStyles.semiBold10(context).copyWith(color: _color),
            ),
            SizedBox(width: 3.w),
            Icon(Icons.arrow_drop_down, color: _color, size: 14.sp),
          ],
        ),
      ),
    );
  }
}

class _CreateCategoryPickerSheet extends StatelessWidget {
  const _CreateCategoryPickerSheet({
    required this.categories,
    required this.selected,
  });

  final List<String> categories;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          SizedBox(height: 16.h),
          Text(
            'Plan type',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          ...categories.map(
            (c) => GestureDetector(
              onTap: () => Navigator.pop(context, c),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c,
                        style: AppTextStyles.medium14(context).copyWith(
                          color: c == selected
                              ? AppColors.buttonColor
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (c == selected)
                      Icon(
                        Icons.check,
                        color: AppColors.buttonColor,
                        size: 18.sp,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note tab ─────────────────────────────────────────────────────────────────

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
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
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
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type Your Note !',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
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
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category badge ───────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFB22A4A);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        category,
        style: AppTextStyles.semiBold10(context).copyWith(color: color),
      ),
    );
  }
}

// ── Assign sheet (real clients, no start_date) ───────────────────────────────

class _AssignToClientSheet extends StatefulWidget {
  const _AssignToClientSheet({required this.template});

  final WorkoutTemplateEntry template;

  @override
  State<_AssignToClientSheet> createState() => _AssignToClientSheetState();
}

class _AssignToClientSheetState extends State<_AssignToClientSheet> {
  late final TextEditingController _searchController;
  String? _selectedRelationId;
  String? _selectedClientName;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Client picked — hand off to the Customize Workout Assignment page,
  /// which performs the actual assignment on confirm.
  void _continue() {
    final relationId = _selectedRelationId;
    final clientName = _selectedClientName;
    if (relationId == null || clientName == null) return;
    Navigator.pop(
      context,
      (relationId: relationId, clientName: clientName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20.r),
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
            SizedBox(height: 16.h),
            Text(
              'Assign "${widget.template.title}"',
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 12.h),
            Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search clients',
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
            ),
            SizedBox(height: 12.h),
            BlocBuilder<CoachClientsCubit, CoachClientsState>(
              builder: (context, state) {
                final clients = state.clients;
                if (state is CoachClientsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CoachClientsError) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.message,
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.read<CoachClientsCubit>().loadClients(),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
                final query = _searchController.text.toLowerCase();
                final filtered = clients
                    .where(
                      (c) =>
                          query.isEmpty || c.name.toLowerCase().contains(query),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No clients found',
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return SizedBox(
                  height: 88.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => SizedBox(width: 16.w),
                    itemBuilder: (context, index) {
                      final CoachAssignedClient client = filtered[index];
                      final isSelected =
                          _selectedRelationId == client.relationId;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRelationId = client.relationId;
                            _selectedClientName = client.name;
                          });
                          context.read<WorkoutPlansCubit>().load(
                            clientId: client.relationId,
                            isActive: true,
                          );
                        },
                      child: Column(
                        children: [
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceDark,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.buttonColor,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 64.w,
                            child: Text(
                              client.name.split(' ').first,
                              style: AppTextStyles.meduim11(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            BlocBuilder<WorkoutPlansCubit, WorkoutPlansState>(
              builder: (context, plansState) {
                if (_selectedRelationId == null) {
                  return const SizedBox.shrink();
                }
                return switch (plansState) {
                  WorkoutPlansInitial() => const SizedBox.shrink(),
                  WorkoutPlansLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox.square(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  WorkoutPlansError() => const SizedBox.shrink(),
                  WorkoutPlansLoaded(:final items) =>
                    items.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active plans for this client',
                                style: AppTextStyles.meduim12(
                                  context,
                                ).copyWith(color: AppColors.textSecondary),
                              ),
                              SizedBox(height: 8.h),
                              ...items.map(
                                (plan) => GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WorkoutPlanDetailScreen(
                                        planId: plan.id,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8.h),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceDark,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            plan.title,
                                            style:
                                                AppTextStyles.medium14(
                                                  context,
                                                ).copyWith(
                                                  color: AppColors.textPrimary,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textSecondary,
                                          size: 18.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                };
              },
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed:
                    _selectedRelationId == null ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
