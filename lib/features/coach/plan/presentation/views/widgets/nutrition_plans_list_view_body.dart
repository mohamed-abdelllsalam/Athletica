import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_plan_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NutritionPlansListViewBody extends StatefulWidget {
  const NutritionPlansListViewBody({super.key});

  @override
  State<NutritionPlansListViewBody> createState() =>
      _NutritionPlansListViewBodyState();
}

class _NutritionPlansListViewBodyState
    extends State<NutritionPlansListViewBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Fat loss',
    'Muscle Gain',
    'Vegan',
    'Custom',
  ];

  static const List<Color> _iconColors = [
    Color(0xFF5A0BFC),
    Color(0xFF3D6BC2),
    Color(0xFFB5541C),
    Color(0xFF1B6E6A),
    Color(0xFF8A2E4A),
    Color(0xFF8A6A2E),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NutritionPlan> get _filtered {
    final plans = NutritionPlansData.plans;
    return plans.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final plans = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(width: 8.w),
              Text(
                "My Nutrition's plans",
                style: AppTextStyles.semiBold15(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Your Nutrition Plan Templates Library',
            style: AppTextStyles.meduim12(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: _SearchBar(
                  controller: _searchController,
                  hint: 'Search Nutrition Plans..',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SizedBox(width: 10.w),
              _CreateButton(onTap: () {}),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return _CategoryChip(
                label: cat,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedCategory = cat),
              );
            },
          ),
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: plans.isEmpty
              ? Center(
                  child: Text(
                    'No plans found',
                    style: AppTextStyles.medium14(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 4.h),
                  itemCount: plans.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final color = _iconColors[index % _iconColors.length];
                    return _NutritionPlanCard(
                      plan: plan,
                      iconColor: color,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NutritionPlanDetailView(plan: plan),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
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
          hintText: hint,
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

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18.sp),
            SizedBox(width: 4.w),
            Text(
              'Create New Plan',
              style: AppTextStyles.meduim12(context)
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.meduim12(context).copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NutritionPlanCard extends StatelessWidget {
  const _NutritionPlanCard({
    required this.plan,
    required this.iconColor,
    required this.onTap,
  });

  final NutritionPlan plan;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: SvgPicture.asset(
                plan.iconAsset,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: AppTextStyles.semiBold14(context).copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _CategoryBadge(category: plan.category),
                    ],
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
                        plan.planDuration,
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          plan.updatedAgo,
                          style: AppTextStyles.meduim12(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Used by ${plan.clientCount} clients',
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  Color get _color => switch (category) {
        'Fat loss' => const Color(0xFF7B4FE8),
        'Muscle Gain' => const Color(0xFF3D6BC2),
        'Vegan' => const Color(0xFF2E8A4A),
        'Custom' => const Color(0xFFB22A4A),
        _ => AppColors.primaryBlue,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        category,
        style: AppTextStyles.semiBold10(context).copyWith(color: _color),
      ),
    );
  }
}
