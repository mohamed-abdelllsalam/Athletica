import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/workout_plan_day_card.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutPlanCreateHeader extends StatelessWidget {
  const WorkoutPlanCreateHeader({
    super.key,
    required this.iconAsset,
    required this.nameController,
    required this.nameHasError,
    required this.dayCount,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  final String iconAsset;
  final TextEditingController nameController;
  final bool nameHasError;
  final int dayCount;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
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
                  autofocus: true,
                  style: AppTextStyles.bold24(
                    context,
                  ).copyWith(color: AppColors.textPrimary, fontSize: 20.sp),
                  decoration: InputDecoration(
                    hintText: 'Plan name',
                    hintStyle: AppTextStyles.bold24(
                      context,
                    ).copyWith(color: AppColors.textSecondary, fontSize: 20.sp),
                    errorText: nameHasError ? 'Required' : null,
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
                      dayCount == 0 ? 'No days yet' : '$dayCount Days Split',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 8.w),
                    _CreateCategorySelector(
                      selected: selectedCategory,
                      categories: categories,
                      onChanged: onCategoryChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Owns its controller so it is disposed with the dialog route itself —
/// never dispose a dialog's controller right after `await showDialog`,
/// the exit animation still paints its TextField.
class WorkoutPlanAddDayDialog extends StatefulWidget {
  const WorkoutPlanAddDayDialog({
    super.key,
    required this.initialTitle,
    this.dialogTitle = 'Add Day',
    this.confirmLabel = 'Add',
  });

  final String initialTitle;
  final String dialogTitle;
  final String confirmLabel;

  @override
  State<WorkoutPlanAddDayDialog> createState() =>
      _WorkoutPlanAddDayDialogState();
}

class _WorkoutPlanAddDayDialogState extends State<WorkoutPlanAddDayDialog> {
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

class WorkoutPlanCreateOverviewTab extends StatelessWidget {
  const WorkoutPlanCreateOverviewTab({
    super.key,
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
                          color:
                              workoutPlanDayColors[i %
                                  workoutPlanDayColors.length],
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
    return WorkoutPlanDayCard(
      dayLabel: 'D${day.dayNumber}',
      title: day.name,
      subtitle: day.isRest ? 'Rest day' : '${day.exerciseCount} Exercises',
      isRest: day.isRest,
      color: color,
      onNavigate: onNavigate,
      actions: [
        WorkoutPlanDayMenuAction(
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
