import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import '../domain/usecases/get_notification_session.dart';

class NotificationSessionRepositoryImpl
    implements NotificationSessionRepository {
  NotificationSessionRepositoryImpl(this.storage);
  final TokenStorageService storage;
  @override
  Future<ApiResult<NotificationSessionSnapshot>> read() async {
    try {
      if (await storage.getToken() == null) {
        return const ApiSuccess(NotificationSessionSnapshot(null, null));
      }
      final role = await storage.getRole();
      final owner = switch (role) {
        'TRAINER' => await storage.getTrainerId(),
        'CLIENT' => await storage.getClientId(),
        _ => null,
      };
      return ApiSuccess(
        NotificationSessionSnapshot(owner, await storage.getSessionStartedAt()),
      );
    } catch (_) {
      return const ApiError(
        ServerFailure('Notification session storage unavailable.'),
      );
    }
  }
}
