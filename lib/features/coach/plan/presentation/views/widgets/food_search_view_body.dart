import 'dart:async';

import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/foods_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/food_search_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoodSearchViewBody extends StatefulWidget {
  const FoodSearchViewBody({
    super.key,
    this.existingFoodIds = const <String>{},
  });

  /// Catalog ids already inside the target meal — rendered pre-marked and
  /// not selectable again.
  final Set<String> existingFoodIds;

  @override
  State<FoodSearchViewBody> createState() => _FoodSearchViewBodyState();
}

class _FoodSearchViewBodyState extends State<FoodSearchViewBody> {
  final TextEditingController _searchController = TextEditingController();

  /// Persisted across searches/filter changes so previously selected foods
  /// are never lost when the visible list shrinks.
  final Map<String, FoodItem> _selectedFoods = {};

  /// Selected category id; null means "All" (no API-side filtering).
  String? _selectedCategoryId;
  Timer? _debounce;

  Set<String> get _existingIds => widget.existingFoodIds;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<FoodsCubit>().search(value);
    });
  }

  void _onFilterChanged(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    context.read<FoodsCubit>().selectCategory(categoryId ?? '');
  }

  List<FoodItem> get _selected => _selectedFoods.values.toList();

  String _summaryText() => _selected.map((f) => f.displayName).join(' / ');

  void _toggleSelection(FoodItem food) {
    if (_existingIds.contains(food.id)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${food.displayName} is already in this meal.'),
          ),
        );
      return;
    }
    setState(() {
      if (_selectedFoods.containsKey(food.id)) {
        _selectedFoods.remove(food.id);
      } else {
        _selectedFoods[food.id] = food;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedFoods.clear();
      _searchController.clear();
      _selectedCategoryId = null;
    });
    context.read<FoodsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodsCubit, FoodsState>(
      builder: (context, state) {
        if (state is FoodsLoading || state is FoodsInitial) {
          return AppShimmer(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: 8,
              itemBuilder: (_, _) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: SkeletonListTile(
                    leadingSize: 40.r,
                    trailingSize: 28.r,
                  ),
                ),
              ),
            ),
          );
        }

        if (state is FoodsError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => context.read<FoodsCubit>().load(),
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

        final loaded = state as FoodsLoaded;
        final filterItems = <({String? id, String label})>[
          const (id: null, label: 'All'),
          ...loaded.categories.map(
            (c) => (id: c.id as String?, label: c.displayName),
          ),
        ];
        final items = loaded.foods;
        final selected = _selected;

        return Column(
          children: [
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  FoodSearchIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context, selected),
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
                        onChanged: _onSearchChanged,
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search',
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
                  ),
                  SizedBox(width: 10.w),
                  FoodSearchIconButton(
                    icon: Icons.delete_outline,
                    onTap: _clearAll,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: loaded.isFiltering
                  ? ClipRRect(
                      key: ValueKey('filtering-${loaded.isFiltering}'),
                      borderRadius: BorderRadius.circular(2.r),
                      child: const LinearProgressIndicator(
                        minHeight: 2,
                        color: AppColors.primaryBlue,
                        backgroundColor: AppColors.surfaceDark,
                      ),
                    )
                  : const SizedBox(height: 2, key: ValueKey('idle')),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              'No foods found',
                              style: AppTextStyles.medium14(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
                            ),
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                      scrollInfo.metrics.maxScrollExtent -
                                          200 &&
                                  loaded.hasMore &&
                                  !loaded.isLoadingMore) {
                                context.read<FoodsCubit>().loadMore();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              itemCount:
                                  items.length + (loaded.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= items.length) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  );
                                }
                                final food = items[index];
                                final isSelected = _selectedFoods.containsKey(
                                  food.id,
                                );
                                final isInMeal = _existingIds.contains(food.id);
                                return Container(
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40.r,
                                        height: 40.r,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceDark,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          food.emoji,
                                          style: TextStyle(fontSize: 20.sp),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          food.displayName,
                                          style: AppTextStyles.medium14(context)
                                              .copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _toggleSelection(food),
                                        child: Container(
                                          width: 28.r,
                                          height: 28.r,
                                          decoration: BoxDecoration(
                                            color: isInMeal
                                                ? AppColors.streakGreen
                                                : isSelected
                                                ? AppColors.primaryBlue
                                                : AppColors.surfaceDark,
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Icon(
                                            isInMeal || isSelected
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: Colors.white,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  SizedBox(width: 10.w),
                  FoodSearchFilterRail(
                    selectedId: _selectedCategoryId,
                    items: filterItems,
                    onChanged: _onFilterChanged,
                  ),
                ],
              ),
            ),
            if (selected.isNotEmpty)
              FoodSearchSummaryBar(
                summaryText: _summaryText(),
                onSubmit: () => Navigator.pop(context, selected),
              ),
          ],
        );
      },
    );
  }
}
