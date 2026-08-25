import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/nutrition/domain/entities/nutrition_history.dart';
import 'package:athletica/features/nutrition/domain/repositories/nutrition_repository.dart';

class GetNutritionHistoryUseCase {
  const GetNutritionHistoryUseCase(this._repository);

  final NutritionRepository _repository;

  /// [from]/[to] default to the API's last-30-days range when null.
  Future<ApiResult<List<NutritionHistoryDay>>> call({
    DateTime? from,
    DateTime? to,
  }) =>
      _repository.getHistory(from: from, to: to);
}
