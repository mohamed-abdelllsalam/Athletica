import 'nutrition_editor_sections.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/presentation/views/food_search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionEditorViewBody extends StatefulWidget {
  const NutritionEditorViewBody({super.key, required this.clientName});

  final String clientName;

  @override
  State<NutritionEditorViewBody> createState() =>
      _NutritionEditorViewBodyState();
}

class _NutritionEditorViewBodyState extends State<NutritionEditorViewBody> {
  int _day = 1;
  List<FoodItem> _breakfast = [];
  List<FoodItem> _lunch = [];
  List<FoodItem> _snack = [];
  List<FoodItem> _dinner = [];

  Future<void> _pickFood(String meal) async {
    final result = await Navigator.push<List<FoodItem>>(
      context,
      MaterialPageRoute(builder: (_) => const FoodSearchView()),
    );
    if (result == null || result.isEmpty) return;
    setState(() {
      switch (meal) {
        case 'breakfast':
          _breakfast = [..._breakfast, ...result];
        case 'lunch':
          _lunch = [..._lunch, ...result];
        case 'snack':
          _snack = [..._snack, ...result];
        case 'dinner':
          _dinner = [..._dinner, ...result];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Upload Pdf Program',
                  style: AppTextStyles.meduim12(context).copyWith(
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CoachNutritionEditorDayCounter(
            day: _day,
            onDecrement: () {
              if (_day > 1) setState(() => _day--);
            },
            onIncrement: () => setState(() => _day++),
          ),
          SizedBox(height: 20.h),
          CoachNutritionEditorMealSection(
            label: 'Breakfast',
            items: _breakfast,
            onAdd: () => _pickFood('breakfast'),
          ),
          SizedBox(height: 16.h),
          CoachNutritionEditorMealSection(
            label: 'Lunch',
            items: _lunch,
            onAdd: () => _pickFood('lunch'),
          ),
          SizedBox(height: 16.h),
          CoachNutritionEditorMealSection(
            label: 'Snack',
            items: _snack,
            onAdd: () => _pickFood('snack'),
          ),
          SizedBox(height: 16.h),
          CoachNutritionEditorMealSection(
            label: 'Dinner',
            items: _dinner,
            onAdd: () => _pickFood('dinner'),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Save',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Done',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
