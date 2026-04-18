import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/plan_exercise.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseSearchViewBody extends StatefulWidget {
  const ExerciseSearchViewBody({super.key});

  @override
  State<ExerciseSearchViewBody> createState() => _ExerciseSearchViewBodyState();
}

class _ExerciseSearchViewBodyState extends State<ExerciseSearchViewBody> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlanExercise> get _filtered {
    if (_query.isEmpty) return ExercisesData.all;
    final lower = _query.toLowerCase();
    return ExercisesData.all
        .where((e) => e.name.toLowerCase().contains(lower))
        .toList();
  }

  List<PlanExercise> get _selected =>
      ExercisesData.all.where((e) => _selectedIds.contains(e.id)).toList();

  String get _summaryText =>
      _selected.map((e) => e.name).join(' / ');

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Column(
      children: [
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _RoundedIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context, _selected),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
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
              _RoundedIconButton(
                icon: Icons.delete_outline,
                onTap: () => setState(() {
                  _selectedIds.clear();
                  _searchController.clear();
                  _query = '';
                }),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final exercise = items[index];
              final selected = _selectedIds.contains(exercise.id);
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    const ExerciseThumbnail(size: 72),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: AppTextStyles.medium14(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedIds.remove(exercise.id);
                        } else {
                          _selectedIds.add(exercise.id);
                        }
                      }),
                      child: Icon(
                        selected ? Icons.bookmark : Icons.bookmark_border,
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_selected.isNotEmpty)
          _SummaryBar(
            summaryText: _summaryText,
            onSubmit: () => Navigator.pop(context, _selected),
          ),
      ],
    );
  }
}

class _RoundedIconButton extends StatelessWidget {
  const _RoundedIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summaryText, required this.onSubmit});

  final String summaryText;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Summary Of Training :',
                style: AppTextStyles.meduim12(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: 200.w,
                child: Text(
                  summaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.meduim12(context)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Submit',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
