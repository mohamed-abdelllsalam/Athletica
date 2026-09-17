import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_templates_list_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_state.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_plan_detail_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plans_list_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      case NutritionTemplatesListLoaded(:final plans, :final isLoadingMore):
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
                context.read<NutritionTemplatesListCubit>().loadTemplates();
              case SaveNutritionPlanError(:final message):
                setState(() => _loading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
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
                  child: NutritionPlansSearchBar(
                    controller: _searchController,
                    hint: 'Search Nutrition Plans..',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                SizedBox(width: 10.w),
                NutritionPlansCreateButton(onTap: _createNewPlan),
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
                return NutritionPlansCategoryChip(
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
                          style: AppTextStyles.medium14(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
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
                            style: AppTextStyles.medium14(
                              context,
                            ).copyWith(color: Colors.white),
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
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    final cubit = context.read<NutritionTemplatesListCubit>();
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200 &&
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
                    itemCount: _filtered.length + (_loadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index >= _filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final plan = _filtered[index];
                      final color = _iconColors[index % _iconColors.length];
                      return NutritionPlanListCard(
                        plan: plan,
                        iconColor: color,
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          final changed = await navigator.push<bool>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  NutritionPlanDetailView(plan: plan),
                            ),
                          );
                          if ((changed ?? false) && context.mounted) {
                            context
                                .read<NutritionTemplatesListCubit>()
                                .loadTemplates();
                          }
                        },
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
