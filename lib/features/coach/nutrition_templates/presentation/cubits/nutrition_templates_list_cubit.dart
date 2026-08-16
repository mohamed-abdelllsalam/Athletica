import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/nutrition_template.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_templates_usecase.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/nutrition_templates_list_state.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NutritionTemplatesListCubit extends Cubit<NutritionTemplatesListState> {
  NutritionTemplatesListCubit(this._getTemplates)
      : super(NutritionTemplatesListInitial());

  final GetNutritionTemplatesUseCase _getTemplates;

  Future<void> loadTemplates() async {
    if (state is NutritionTemplatesListLoading) return;
    emit(NutritionTemplatesListLoading());

    final result = await _getTemplates();
    switch (result) {
      case ApiSuccess(:final data):
        emit(NutritionTemplatesListLoaded(data.map(_toPlan).toList()));
      case ApiError(:final failure):
        emit(NutritionTemplatesListError(failure.message));
    }
  }

  NutritionPlan _toPlan(NutritionTemplate t) => NutritionPlan(
        id: t.id,
        name: t.title,
        category: 'Custom',
        calories: t.totalCalories,
        proteinGrams: t.totalProtein,
        fatGrams: t.totalFat,
        carbsGrams: t.totalCarb,
        planDuration: '—',
        updatedAgo: _timeAgo(t.updatedAt),
        clientCount: 0,
        meals: const [],
        description: t.description,
        iconAsset: 'assets/images/plan/nutrition_icon.svg',
      );

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
