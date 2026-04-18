import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_plan_client.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_editor_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientPlanDetailViewBody extends StatefulWidget {
  const ClientPlanDetailViewBody({super.key, required this.client});

  final CoachPlanClient client;

  @override
  State<ClientPlanDetailViewBody> createState() =>
      _ClientPlanDetailViewBodyState();
}

class _ClientPlanDetailViewBodyState extends State<ClientPlanDetailViewBody> {
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fatController.text = widget.client.fatGrams.toString();
    _proteinController.text = widget.client.proteinGrams.toString();
    _carbController.text = widget.client.carbGrams.toString();
  }

  @override
  void dispose() {
    _fatController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    super.dispose();
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20.sp),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              widget.client.name,
              style: AppTextStyles.bold24(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: '+ Add workout',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WorkoutEditorView(clientName: widget.client.name),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _ActionButton(
                  label: '+ Add Nutrition',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NutritionEditorView(clientName: widget.client.name),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Fat',
            style: AppTextStyles.semiBold14(context)
                .copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          _MacroField(controller: _fatController, hint: 'Type Fat'),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protein',
                      style: AppTextStyles.semiBold14(context)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8.h),
                    _MacroField(
                        controller: _proteinController, hint: 'Type Protein'),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carb',
                      style: AppTextStyles.semiBold14(context)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8.h),
                    _MacroField(
                        controller: _carbController, hint: 'Type Carb'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryBlue),
        foregroundColor: AppColors.primaryBlue,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      icon: Container(
        width: 20.r,
        height: 20.r,
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: Colors.white, size: 14.sp),
      ),
      label: Text(
        label.replaceFirst('+ ', ''),
        style: AppTextStyles.meduim12(context)
            .copyWith(color: AppColors.primaryBlue),
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: AppTextStyles.medium14(context)
            .copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }
}
