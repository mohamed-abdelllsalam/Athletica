import 'package:athletica/core/utils/api_result.dart';

class NotificationSessionSnapshot {
  const NotificationSessionSnapshot(this.owner, this.startedAt);
  final String? owner;
  final DateTime? startedAt;
  bool allows(DateTime? sentTime) =>
      owner != null &&
      (startedAt == null ||
          (sentTime != null && !sentTime.isBefore(startedAt!)));
}

abstract interface class NotificationSessionRepository {
  Future<ApiResult<NotificationSessionSnapshot>> read();
}

class GetNotificationSession {
  GetNotificationSession(this.repository);
  final NotificationSessionRepository repository;
  Future<ApiResult<NotificationSessionSnapshot>> call() => repository.read();
}
