import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/coach/plan/presentation/cubits/foods_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/food_search_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodSearchView extends StatelessWidget {
  const FoodSearchView({
    super.key,
    this.existingFoodIds = const <String>{},
  });

  /// Catalog ids already inside the target meal — shown pre-marked and not
  /// selectable again.
  final Set<String> existingFoodIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FoodsCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        body: SafeArea(
          child: FoodSearchViewBody(existingFoodIds: existingFoodIds),
        ),
      ),
    );
  }
}
