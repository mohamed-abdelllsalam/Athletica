import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_templates_list_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/save_nutrition_plan_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plans_list_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NutritionPlansListView extends StatelessWidget {
  const NutritionPlansListView({super.key});

  static const String routeName = 'nutrition-plans-list';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // .value — the cubit is an app-lifetime singleton; a plain
        // BlocProvider would close it on pop and break later reopens.
        BlocProvider.value(
          value: sl<NutritionTemplatesListCubit>()..loadTemplates(),
        ),
        BlocProvider(create: (_) => sl<SaveNutritionPlanCubit>()),
      ],
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: NutritionPlansListViewBody()),
      ),
    );
  }
}
