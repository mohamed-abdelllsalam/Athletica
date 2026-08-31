import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class CheckClientProfileCompletionUseCase {
  const CheckClientProfileCompletionUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<bool>> call() => _repository.checkClientProfileCompletion();
}
