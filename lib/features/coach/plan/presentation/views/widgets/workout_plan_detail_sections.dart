import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/workout_plan_day_card.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutPlanDetailContent extends StatelessWidget {
  const WorkoutPlanDetailContent({
    super.key,
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
        _DetailActionBar(
          mutating: mutating,
          onExit: onExit,
          onDelete: onDeleteTemplate,
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
              WorkoutPlanNoteTab(controller: noteController),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Overview tab ─────────────────────────────────────────────────────────────

class _DetailActionBar extends StatelessWidget {
  const _DetailActionBar({
    required this.mutating,
    required this.onExit,
    required this.onDelete,
  });

  final bool mutating;
  final VoidCallback onExit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onTap: mutating ? null : onDelete,
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
    );
  }
}

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

  List<WorkoutPlanDayMenuAction> _menuFor(TemplateDayEntry day) => [
    if (!day.isRest)
      const WorkoutPlanDayMenuAction(
        value: 'add',
        label: 'Add exercises',
        icon: Icons.add,
      ),
    WorkoutPlanDayMenuAction(
      value: 'rest',
      label: day.isRest ? 'Remove rest day' : 'Make as a rest day',
      icon: day.isRest ? Icons.bedtime : Icons.bedtime_outlined,
    ),
    const WorkoutPlanDayMenuAction(
      value: 'rename',
      label: 'Rename',
      icon: Icons.edit_outlined,
    ),
    const WorkoutPlanDayMenuAction(
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
                        child: WorkoutPlanDayCard(
                          dayLabel: 'D${days[i].dayNumber}',
                          title: days[i].title,
                          subtitle: days[i].isRest
                              ? 'Rest day'
                              : '${days[i].exerciseCount} Exercises',
                          isRest: days[i].isRest,
                          color:
                              workoutPlanDayColors[i %
                                  workoutPlanDayColors.length],
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

// ── Create-mode overview tab (local days, like nutrition Add Meal) ──────────

class WorkoutPlanNoteTab extends StatelessWidget {
  const WorkoutPlanNoteTab({super.key, required this.controller});

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
