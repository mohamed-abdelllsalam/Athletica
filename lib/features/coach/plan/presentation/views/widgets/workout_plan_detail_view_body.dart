import 'workout_plan_detail_states.dart';
import 'workout_plan_create_content.dart';
import 'workout_plan_note_tab.dart';
import 'workout_plan_dialogs.dart';
import 'workout_plan_add_day_dialog.dart';
import 'workout_plan_create_overview_tab.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/customize_workout_assignment_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/exercise_library_picker_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_day_exercises_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plan_detail_sections.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plan_assign_client_sheet.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/workout_plan_create_sections.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_state.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      builder: (_) => CoachWorkoutPlanUnsavedChangesDialog(
        titleStyle: AppTextStyles.semiBold14(context),
        bodyStyle: AppTextStyles.medium14(context),
        onSaveAndExit: () => Navigator.pop(context, 'saveExit'),
        onDiscard: () => Navigator.pop(context, 'discard'),
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
      builder: (_) => WorkoutPlanAddDayDialog(
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
      builder: (_) => CoachWorkoutPlanDeleteDayDialog(
        titleStyle: AppTextStyles.semiBold14(context),
        bodyStyle: AppTextStyles.medium14(context),
        onCancel: () => Navigator.pop(context, false),
        onDelete: () => Navigator.pop(context, true),
        dayTitle: day.title,
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
      builder: (_) => WorkoutPlanAddDayDialog(
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
      child: CoachWorkoutPlanCreateContent(
        header: WorkoutPlanCreateHeader(
          iconAsset: _currentIconAsset,
          nameController: _nameController,
          nameHasError: _nameHasError,
          dayCount: _days.length,
          selectedCategory: _selectedCategory,
          categories: _createCategories,
          onCategoryChanged: (value) =>
              setState(() => _selectedCategory = value),
        ),
        overview: WorkoutPlanCreateOverviewTab(
          descriptionController: _descriptionController,
          descriptionHasError: _descriptionHasError,
          days: _days,
          onAddDay: _addDayLocal,
          onOpenDay: _handleDayTapByIndex,
          onToggleRest: _toggleRestLocal,
          onReorder: _reorderLocal,
        ),
        note: WorkoutPlanNoteTab(controller: _noteController),
        tabController: _tabController,
        onExit: _exitWithResolution,
        onSave: _trySavePlan,
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
              WorkoutTemplateDetailError(:final message) =>
                CoachWorkoutPlanDetailError(
                  message: message,
                  onRetry: () => context
                      .read<WorkoutTemplateDetailCubit>()
                      .load(widget.program.id),
                ),
              WorkoutTemplateDetailLoaded(:final template, :final mutating) =>
                WorkoutPlanDetailContent(
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
      builder: (_) => CoachWorkoutPlanDeleteDialog(
        titleStyle: AppTextStyles.bold20(context),
        bodyStyle: AppTextStyles.medium14(context),
        onCancel: () => Navigator.pop(context, false),
        onDelete: () => Navigator.pop(context, true),
        templateTitle: template.title,
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

  void _showAssignSheet(
    BuildContext context,
    WorkoutTemplateEntry template,
  ) async {
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
            child: WorkoutPlanAssignClientSheet(template: template),
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
    if (!context.mounted || assignedPlanId == null || assignedPlanId.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout assigned successfully')),
    );
  }
}
