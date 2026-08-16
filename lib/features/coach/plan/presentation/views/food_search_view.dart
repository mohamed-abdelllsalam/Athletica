import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/foods_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/food_search_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodSearchView extends StatelessWidget {
  const FoodSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FoodsCubit>()..load(),
      child: const Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(child: FoodSearchViewBody()),
      ),
    );
  }
}
