import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/today_meals.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';

class GetTodayMealsUseCase {
  const GetTodayMealsUseCase(this._repository);

  final NutritionRepository _repository;

  Future<ApiResult<TodayMeals>> call() => _repository.getTodayMeals();
}
