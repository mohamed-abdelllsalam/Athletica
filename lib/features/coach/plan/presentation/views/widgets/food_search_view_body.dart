import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> get _filtered {
    if (_query.isEmpty) return FoodItemsData.all;
    final lower = _query.toLowerCase();
    return FoodItemsData.all
        .where((f) => f.name.toLowerCase().contains(lower))
        .toList();
  }

  List<FoodItem> get _selected =>
      FoodItemsData.all.where((f) => _selectedIds.contains(f.id)).toList();

  String get _summaryText {
    final names = _selected.map((f) => f.name).join(' / ');
    return names.isEmpty ? '' : names;
  }

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
              final food = items[index];
              final selected = _selectedIds.contains(food.id);
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
                    Text(food.emoji, style: TextStyle(fontSize: 32.sp)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        food.name,
                        style: AppTextStyles.medium14(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Gram',
                        style: AppTextStyles.meduim12(context)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedIds.remove(food.id);
                        } else {
                          _selectedIds.add(food.id);
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
              backgroundColor: AppColors.buttonColor,
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
