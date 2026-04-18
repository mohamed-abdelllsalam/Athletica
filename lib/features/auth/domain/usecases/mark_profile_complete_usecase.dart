import 'package:athletica/features/auth/domain/repositories/auth_repository.dart';

class MarkProfileCompleteUseCase {
  final AuthRepository _repository;

  const MarkProfileCompleteUseCase(this._repository);

  Future<void> call() => _repository.markProfileComplete();
}
