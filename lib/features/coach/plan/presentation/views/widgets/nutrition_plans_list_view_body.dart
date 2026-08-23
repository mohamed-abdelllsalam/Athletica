import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_templates_list_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_state.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_plan_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  List<NutritionPlan> _apiPlans = [];
  bool _loading = false;
  bool _loadedOnce = false;
  bool _loadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Seed from the cached cubit state so reopening the screen shows the
    // last-known list instantly while it silently revalidates in the
    // background (bloc listeners do not replay the current state).
    switch (context.read<NutritionTemplatesListCubit>().state) {
      case NutritionTemplatesListLoaded(
          :final plans,
          :final isLoadingMore,
        ):
        setState(() {
          _apiPlans = plans;
          _loadingMore = isLoadingMore;
          _loadedOnce = true;
        });
      case NutritionTemplatesListLoading():
        setState(() => _loading = true);
      case NutritionTemplatesListError(:final message):
        setState(() => _errorMessage = message);
      case NutritionTemplatesListInitial():
        break;
    }
  }

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
    return _apiPlans.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesQuery =
          _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _createNewPlan() async {
    final plan = NutritionPlan(
      id: 'np_${DateTime.now().millisecondsSinceEpoch}',
      name: '',
      category: 'Custom',
      calories: 0,
      proteinGrams: 0,
      fatGrams: 0,
      carbsGrams: 0,
      planDuration: '4 Week Plan',
      updatedAgo: 'Just created',
      clientCount: 0,
      meals: [],
      description: '',
      iconAsset: 'assets/images/plan/nutrition_icon.svg',
    );
    final result = await Navigator.push<NutritionPlan>(
      context,
      MaterialPageRoute(
        builder: (_) => NutritionPlanDetailView(plan: plan, isCreateMode: true),
      ),
    );
    if (result != null && mounted) {
      context.read<SaveNutritionPlanCubit>().savePlan(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NutritionTemplatesListCubit, NutritionTemplatesListState>(
          listener: (context, state) {
            switch (state) {
              case NutritionTemplatesListLoading():
                setState(() {
                  _loading = true;
                  _errorMessage = null;
                });
              case NutritionTemplatesListLoaded(
                  :final plans,
                  :final isLoadingMore,
                ):
                setState(() {
                  _apiPlans = plans;
                  _loading = false;
                  _loadedOnce = true;
                  _loadingMore = isLoadingMore;
                });
              case NutritionTemplatesListError(:final message):
                setState(() {
                  _loading = false;
                  _loadingMore = false;
                  _errorMessage = message;
                });
              case NutritionTemplatesListInitial():
                break;
            }
          },
        ),
        BlocListener<SaveNutritionPlanCubit, SaveNutritionPlanState>(
          listener: (context, state) {
            switch (state) {
              case SaveNutritionPlanLoading():
                setState(() => _loading = true);
              case SaveNutritionPlanSuccess():
                context
                    .read<NutritionTemplatesListCubit>()
                    .loadTemplates();
              case SaveNutritionPlanError(:final message):
                setState(() => _loading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.red,
                  ),
                );
              case SaveNutritionPlanIdle():
                break;
            }
          },
        ),
      ],
      child: Column(
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
                  style: AppTextStyles.semiBold15(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Your Nutrition Plan Templates Library',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
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
                _CreateButton(onTap: _createNewPlan),
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
            child: Builder(
              builder: (context) {
                // First open with nothing cached yet: shimmer until the
                // first result arrives (loading state or initial fetch).
                if (_loading || (!_loadedOnce && _errorMessage == null)) {
                  return AppShimmer(
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: 6,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (_, _) =>
                          SkeletonBox(height: 88.h, radius: 14.r),
                    ),
                  );
                }
                if (_errorMessage != null && _apiPlans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          style: AppTextStyles.medium14(context)
                              .copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context
                              .read<NutritionTemplatesListCubit>()
                              .loadTemplates(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: Text(
                            'Retry',
                            style: AppTextStyles.medium14(context)
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (_filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No plans found',
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    final cubit = context.read<NutritionTemplatesListCubit>();
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent -
                                200 &&
                        !_loadingMore) {
                      cubit.loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 4.h,
                    ),
                    itemCount: _filtered.length +
                        (_loadingMore ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index >= _filtered.length) {
                        return const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final plan = _filtered[index];
                      final color =
                          _iconColors[index % _iconColors.length];
                      return _NutritionPlanCard(
                        plan: plan,
                        iconColor: color,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NutritionPlanDetailView(
                                plan: plan),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
        style: AppTextStyles.medium14(
          context,
        ).copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
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
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: Colors.white),
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
              child: SvgPicture.asset(plan.iconAsset, fit: BoxFit.contain),
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
                          plan.name.isEmpty ? 'Unnamed Plan' : plan.name,
                          style: AppTextStyles.semiBold14(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
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
                        Icons.local_fire_department_outlined,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${plan.calories} kcal  •  ${plan.proteinGrams}g protein',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        plan.updatedAgo,
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
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
