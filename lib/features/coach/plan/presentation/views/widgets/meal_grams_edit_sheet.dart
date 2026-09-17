import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealGramsEditSheet extends StatefulWidget {
  const MealGramsEditSheet({
    super.key,
    required this.ingredientName,
    required this.currentGrams,
  });

  final String ingredientName;
  final int currentGrams;

  @override
  State<MealGramsEditSheet> createState() => _MealGramsEditSheetState();
}

class _MealGramsEditSheetState extends State<MealGramsEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentGrams.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.ingredientName,
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              'Edit serving size in grams',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold24(
                        context,
                      ).copyWith(color: AppColors.textPrimary, fontSize: 20.sp),
                      onSubmitted: (_) => _confirm(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Text(
                      'g',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note Tab ──────────────────────────────────────────────────────────────────
