import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/foods_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoodSearchViewBody extends StatefulWidget {
  const FoodSearchViewBody({super.key});

  @override
  State<FoodSearchViewBody> createState() => _FoodSearchViewBodyState();
}

class _FoodSearchViewBodyState extends State<FoodSearchViewBody> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _query = '';
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> _filtered(List<FoodItem> all) {
    final lower = _query.toLowerCase();
    return all.where((f) {
      final matchesQuery =
          _query.isEmpty || f.name.toLowerCase().contains(lower);
      final matchesFilter =
          _selectedFilter == 'All' || f.category == _selectedFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<FoodItem> _selected(List<FoodItem> all) =>
      all.where((f) => _selectedIds.contains(f.id)).toList();

  String _summaryText(List<FoodItem> all) {
    final names = _selected(all).map((f) => f.name).join(' / ');
    return names.isEmpty ? '' : names;
  }

  void _clearAll() {
    setState(() {
      _selectedIds.clear();
      _searchController.clear();
      _query = '';
      _selectedFilter = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodsCubit, FoodsState>(
      builder: (context, state) {
        if (state is FoodsLoading || state is FoodsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        if (state is FoodsError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
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
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final loaded = state as FoodsLoaded;
        final filters = [
          'All',
          ...loaded.categories.map((c) => c.name),
        ];
        final items = _filtered(loaded.foods);
        final selected = _selected(loaded.foods);

        return Column(
          children: [
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _RoundedIconButton(
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
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyles.medium14(context)
                            .copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: AppTextStyles.medium14(context)
                              .copyWith(color: AppColors.textSecondary),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _RoundedIconButton(
                    icon: Icons.delete_outline,
                    onTap: _clearAll,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final food = items[index];
                        final isSelected = _selectedIds.contains(food.id);
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
                                  borderRadius: BorderRadius.circular(12.r),
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
                                  food.name,
                                  style: AppTextStyles.medium14(context)
                                      .copyWith(color: AppColors.textPrimary),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  if (isSelected) {
                                    _selectedIds.remove(food.id);
                                  } else {
                                    _selectedIds.add(food.id);
                                  }
                                }),
                                child: Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
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
                  SizedBox(width: 10.w),
                  _FilterRail(
                    selected: _selectedFilter,
                    filters: filters,
                    onChanged: (value) =>
                        setState(() => _selectedFilter = value),
                  ),
                ],
              ),
            ),
            if (selected.isNotEmpty)
              _SummaryBar(
                summaryText: _summaryText(loaded.foods),
                onSubmit: () => Navigator.pop(context, selected),
              ),
          ],
        );
      },
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

class _FilterRail extends StatelessWidget {
  const _FilterRail({
    required this.selected,
    required this.filters,
    required this.onChanged,
  });

  final String selected;
  final List<String> filters;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84.w,
      margin: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _FilterIconButton(icon: Icons.filter_alt_outlined),
          SizedBox(height: 8.h),
          _FilterIconButton(icon: Icons.tune),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: filters.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = filter == selected;
                return GestureDetector(
                  onTap: () => onChanged(filter),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      filter,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.meduim12(context).copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
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

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 18.sp),
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
                'Summary Of Meal :',
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
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
