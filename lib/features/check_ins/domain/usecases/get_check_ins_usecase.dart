import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

class GetCheckInsUseCase {
  const GetCheckInsUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<List<CheckIn>>> call({
    String query = '',
    CheckInStatus? status,
  }) async {
    final result = await _repository.getCheckIns();
    return switch (result) {
      ApiError(:final failure) => ApiError(failure),
      ApiSuccess(:final data) => ApiSuccess(
        List.unmodifiable(
          data.where(
            (entry) =>
                (status == null || entry.status == status) &&
                entry.clientName.toLowerCase().contains(
                  query.trim().toLowerCase(),
                ),
          ),
        ),
      ),
    };
  }
}
