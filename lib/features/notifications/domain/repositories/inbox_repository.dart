import 'package:athletica/core/utils/api_result.dart';
import '../entities/inbox_notification.dart';

abstract class InboxRepository {
  Future<ApiResult<InboxPage>> fetch(
    int generation, {
    String? cursor,
    required bool autoRead,
  });
  Future<ApiResult<int>> unread(int generation);
  Future<ApiResult<void>> markRead(String id, int generation);
  Future<ApiResult<int>> markAll(int generation);
  Future<InboxPage?> cached(String owner);
  Future<void> cache(String owner, InboxPage page);
  Future<void> clear(String owner);
  void cancel();
}
