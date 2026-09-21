import 'workout_plan_overview_tab.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
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
    required this.nameController,
    required this.descriptionController,
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
  final TextEditingController nameController;
  final TextEditingController descriptionController;
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
        Expanded(
          child: CoachWorkoutPlanOverviewTab(
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
