import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/check_ins/domain/repositories/check_ins_repository.dart';

/// Assigns a pending check-in (`C6`). [coachClientId] is `coach_clients.id`
/// (the coach↔client link row), never `user.id` or `client_profiles.id`.
/// Upsert semantics: re-assigning refreshes `pending`.
class AssignCheckInUseCase {
  const AssignCheckInUseCase(this._repository);
  final CheckInsRepository _repository;

  Future<ApiResult<void>> call({required String coachClientId}) =>
      _repository.assignCheckin(coachClientId: coachClientId);
}
