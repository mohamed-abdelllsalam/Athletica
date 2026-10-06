import 'food_search_result.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'food_search_header.dart';
import 'food_search_states.dart';
import 'dart:async';

import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
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
  late final TextEditingController _searchController;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

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
          return CoachFoodSearchLoading();
        }

        if (state is FoodsError) {
          if (state.connectionError) {
            return ConnectionErrorView(
              onRetry: () => context.read<FoodsCubit>().retry(),
            );
          }
          return CoachFoodSearchError(
            message: state.message,
            onRetry: () => context.read<FoodsCubit>().load(),
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
            if (loaded.connectionError)
              ConnectionErrorView(
                compact: true,
                onRetry: () => context.read<FoodsCubit>().retry(),
              ),
            SizedBox(height: 12.h),
            CoachFoodSearchHeader(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onBack: () => Navigator.pop(context, selected),
              onClear: _clearAll,
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
                                return CoachFoodSearchResult(
                                  food: food,
                                  isSelected: isSelected,
                                  isInMeal: isInMeal,
                                  onToggle: () => _toggleSelection(food),
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
