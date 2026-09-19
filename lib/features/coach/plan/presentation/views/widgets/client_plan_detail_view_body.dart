import 'client_plan_macro_form.dart';
import 'client_plan_action_button.dart';
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
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              widget.client.name,
              style: AppTextStyles.bold24(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: CoachClientPlanActionButton(
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
                child: CoachClientPlanActionButton(
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
          CoachClientPlanMacroForm(
            fatController: _fatController,
            proteinController: _proteinController,
            carbController: _carbController,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
