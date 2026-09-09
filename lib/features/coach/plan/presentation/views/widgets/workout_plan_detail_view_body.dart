import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_state.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/exercise_library_picker_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_day_exercises_view.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_plans_state.dart';
import 'package:athletica/features/workout/presentation/views/workout_plan_detail_screen.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_template_detail_state.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.program.name);
    _descriptionController =
        TextEditingController(text: widget.program.description);
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _isArabic() =>
      Localizations.localeOf(context).languageCode == 'ar';

  ProgramDay _toProgramDay(TemplateDayEntry d) => ProgramDay(
        dayNumber: d.dayNumber,
        name: d.title,
        durationMinutes: 60,
        exercises: d.exercises
            .map(
              (e) => ProgramExercise(
                id: e.exerciseId,
                name: e.exercise?.localizedName(_isArabic()) ?? e.exerciseId,
              ),
            )
            .toList(),
      );

  Future<void> _addDay() async {
    final current = context.read<WorkoutTemplateDetailCubit>().state;
    if (current is! WorkoutTemplateDetailLoaded) return;
    final title = await showDialog<String>(
      context: context,
      builder: (_) =>
          _AddDayDialog(initialTitle: 'Day ${current.template.days.length + 1}'),
    );
    if (title == null || title.isEmpty || !mounted) return;
    final ok =
        await context.read<WorkoutTemplateDetailCubit>().addDay(title);
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
          style: AppTextStyles.semiBold14(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remove "${day.title}" and its exercises?',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
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
    final ok =
        await context.read<WorkoutTemplateDetailCubit>().removeDay(day.id);
    if (!mounted) return;
    if (!ok) _showMutationError();
  }

  Future<void> _toggleRest(TemplateDayEntry day) async {
    final ok = await context
        .read<WorkoutTemplateDetailCubit>()
        .editDay(day.id, isRest: !day.isRest);
    if (!mounted) return;
    if (!ok) _showMutationError();
  }

  Future<void> _openDay(TemplateDayEntry day) async {
    final updated = await Navigator.push<List<ProgramExercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDayExercisesView(day: _toProgramDay(day)),
      ),
    );
    if (updated == null || !mounted) return;
    await _reconcileExercises(day, updated);
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

    final toRemove =
        day.exercises.where((e) => !updatedIds.contains(e.exerciseId));
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
    final liveDay = current.template.days.firstWhere((d) => d.id == day.id,
        orElse: () => day);
    final result = await Navigator.push<List<LibraryExercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseLibraryPickerView(
          alreadyAddedIds:
              liveDay.exercises.map((e) => e.exerciseId).toSet(),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutTemplateDetailCubit,
        WorkoutTemplateDetailState>(
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
        WorkoutTemplateDetailLoading() =>
          const Center(child: CircularProgressIndicator()),
        WorkoutTemplateDetailError(:final message) => Center(
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
            onOpenDay: _openDay,
            onAddExercises: _pickAndAddExercises,
            onShowAssign: () => _showAssignSheet(context, template),
            onSaveTitle: () async {
              final ok = await context
                  .read<WorkoutTemplateDetailCubit>()
                  .rename(
                    title: _nameController.text.trim().isEmpty
                        ? null
                        : _nameController.text.trim(),
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                  );
              if (!context.mounted) return;
              if (!ok) _showMutationError();
            },
          ),
      },
    );
  }

  void _showAssignSheet(BuildContext context, WorkoutTemplateEntry template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<WorkoutTemplateDetailCubit>(),
          ),
          BlocProvider.value(value: context.read<CoachClientsCubit>()),
          BlocProvider.value(value: context.read<WorkoutPlansCubit>()),
        ],
        child: _AssignToClientSheet(template: template),
      ),
    );
  }
}

/// Owns its controller so it is disposed with the dialog route itself —
/// never dispose a dialog's controller right after `await showDialog`,
/// the exit animation still paints its TextField.
class _AddDayDialog extends StatefulWidget {
  const _AddDayDialog({required this.initialTitle});

  final String initialTitle;

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
        'Add Day',
        style: AppTextStyles.semiBold14(context)
            .copyWith(color: AppColors.textPrimary),
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
          child: const Text('Add'),
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
    required this.onOpenDay,
    required this.onAddExercises,
    required this.onShowAssign,
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
  final ValueChanged<TemplateDayEntry> onOpenDay;
  final ValueChanged<TemplateDayEntry> onAddExercises;
  final VoidCallback onShowAssign;
  final VoidCallback onSaveTitle;

  static const List<Color> _dayColors = [
    Color(0xFF3D2E8A),
    Color(0xFF2E5EA8),
    Color(0xFF2E8A4A),
    Color(0xFFB5541C),
    Color(0xFF6A2E8A),
    Color(0xFF1B6E6A),
  ];

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
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
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
                child: SvgPicture.asset(
                  program.iconAsset,
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
                      style: AppTextStyles.meduim12(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: nameController,
                      onSubmitted: (_) => onSaveTitle(),
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
                          style: AppTextStyles.meduim12(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const _CategoryBadge(category: 'Custom'),
                        if (mutating) ...[
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 14.r,
                            height: 14.r,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2),
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
              icon: Icon(Icons.person_outline,
                  color: Colors.white, size: 18.sp),
              label: Text(
                'Assign to client',
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: Colors.white,
                ),
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
            tabs: const [Tab(text: 'Overview'), Tab(text: 'Note')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _OverviewTab(
                descriptionController: descriptionController,
                template: template,
                dayColors: _dayColors,
                onAddDay: onAddDay,
                onRemoveDay: onRemoveDay,
                onToggleRest: onToggleRest,
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
    required this.dayColors,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onToggleRest,
    required this.onNavigateDay,
    required this.onAddExercises,
    required this.onSaveTitle,
  });

  final TextEditingController descriptionController;
  final WorkoutTemplateEntry template;
  final List<Color> dayColors;
  final VoidCallback onAddDay;
  final ValueChanged<TemplateDayEntry> onRemoveDay;
  final ValueChanged<TemplateDayEntry> onToggleRest;
  final ValueChanged<TemplateDayEntry> onNavigateDay;
  final ValueChanged<TemplateDayEntry> onAddExercises;
  final VoidCallback onSaveTitle;

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
          style: AppTextStyles.semiBold14(context).copyWith(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: descriptionController,
          maxLines: null,
          onSubmitted: (_) => onSaveTitle(),
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: 'Add a program description…',
            hintStyle: AppTextStyles.medium14(context)
                .copyWith(color: AppColors.textTertiary),
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
              style: AppTextStyles.semiBold14(context).copyWith(
                color: AppColors.textPrimary,
              ),
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
                    Icon(Icons.add,
                        color: AppColors.buttonColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add New Day',
                      style: AppTextStyles.meduim12(context).copyWith(
                        color: AppColors.buttonColor,
                      ),
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
                'No days yet — tap + Add New Day',
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...List.generate(days.length, (i) {
            final day = days[i];
            final color = dayColors[i % dayColors.length];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _DayRow(
                day: day,
                color: color,
                onDelete: () => onRemoveDay(day),
                onToggleRest: () => onToggleRest(day),
                onNavigate: () => onNavigateDay(day),
                onAddExercises: () => onAddExercises(day),
              ),
            );
          }),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.color,
    required this.onDelete,
    required this.onToggleRest,
    required this.onNavigate,
    required this.onAddExercises,
  });

  final TemplateDayEntry day;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onToggleRest;
  final VoidCallback onNavigate;
  final VoidCallback onAddExercises;

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
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                'D${day.dayNumber}',
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.title,
                  style: AppTextStyles.medium14(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  day.isRest
                      ? 'Rest day'
                      : '${day.exerciseCount} Exercises',
                  style: AppTextStyles.meduim12(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!day.isRest)
            GestureDetector(
              onTap: onAddExercises,
              child: Icon(Icons.add,
                  color: AppColors.buttonColor, size: 20.sp),
            ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onToggleRest,
            child: Icon(
              day.isRest ? Icons.bedtime_outlined : Icons.bedtime,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close,
                color: AppColors.textSecondary, size: 20.sp),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onNavigate,
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16.sp,
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
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String? _selectedRelationId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _titleController = TextEditingController(text: widget.template.title);
    _descController =
        TextEditingController(text: widget.template.description);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final relationId = _selectedRelationId;
    if (relationId == null || _submitting) return;
    setState(() => _submitting = true);
    final planId =
        await context.read<WorkoutTemplateDetailCubit>().assign(
              coachClientId: relationId,
              title: _titleController.text.trim().isEmpty
                  ? null
                  : _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
            );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (planId == null) {
      final err = context.read<WorkoutTemplateDetailCubit>().lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Assignment failed')),
      );
      return;
    }
    // Refresh assigned plans for that client per API docs (assign → GET plans).
    await context.read<WorkoutPlansCubit>().load(
          clientId: relationId,
          isActive: true,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout assigned successfully')),
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
              style: AppTextStyles.semiBold15(context)
                  .copyWith(color: AppColors.textPrimary),
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
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search clients',
                  hintStyle: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.textSecondary, size: 20.sp),
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
                          style: AppTextStyles.medium14(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
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
                          query.isEmpty ||
                          c.name.toLowerCase().contains(query),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No clients found',
                      style: AppTextStyles.medium14(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
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
                          setState(() =>
                              _selectedRelationId = client.relationId);
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
                                        color: AppColors.buttonColor, width: 2)
                                    : null,
                              ),
                              child: Icon(Icons.person,
                                  color: AppColors.textSecondary, size: 26.sp),
                            ),
                            SizedBox(height: 4.h),
                            SizedBox(
                              width: 64.w,
                              child: Text(
                                client.name.split(' ').first,
                                style: AppTextStyles.meduim11(context).copyWith(
                                  color: AppColors.textSecondary,
                                ),
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
                        child:
                            SizedBox.square(child: CircularProgressIndicator()),
                      ),
                    ),
                  WorkoutPlansError() => const SizedBox.shrink(),
                  WorkoutPlansLoaded(:final items) => items.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active plans for this client',
                              style: AppTextStyles.meduim12(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
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
                                              AppTextStyles.medium14(context)
                                                  .copyWith(
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
            SizedBox(height: 12.h),
            TextField(
              controller: _titleController,
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Plan title (optional)',
                hintStyle: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _descController,
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Plan description (optional)',
                hintStyle: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: (_selectedRelationId == null || _submitting)
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _submitting
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit',
                        style: AppTextStyles.semiBold14(context).copyWith(
                          color: Colors.white,
                        ),
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
