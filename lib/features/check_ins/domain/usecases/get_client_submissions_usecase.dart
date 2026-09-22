import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Client history (`L4`), newest first. Refreshed after submit alongside the
/// pending flag, following the existing reload conventions.
class GetClientSubmissionsUseCase {
  const GetClientSubmissionsUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<List<CheckInSubmission>>> call() =>
      _repository.getClientSubmissions();
}
