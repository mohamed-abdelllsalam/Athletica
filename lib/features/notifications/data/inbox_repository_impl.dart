import 'dart:convert';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/network/api_endpoints.dart';
import 'package:athletica/core/services/auth_session_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/inbox_notification.dart';
import '../domain/repositories/inbox_repository.dart';

class InboxNotificationModel {
  static InboxNotification parse(dynamic value) {
    if (value is! Map) throw const FormatException('Invalid notification');
    String requiredString(String key) {
      final text = value[key];
      if (text is! String || text.trim().isEmpty) {
        throw FormatException('Invalid $key');
      }
      return text;
    }

    final id = requiredString('id');
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(id)) {
      throw const FormatException('Invalid notification id');
    }
    final rawData = value['data'];
    if (rawData != null && rawData is! Map) {
      throw const FormatException('Invalid notification data');
    }
    final data = <String, String>{};
    if (rawData is Map) {
      for (final entry in rawData.entries) {
        if (entry.key is! String || entry.value is! String) {
          throw const FormatException('Invalid notification data');
        }
        data[entry.key as String] = entry.value as String;
      }
    }
    if (value['is_read'] is! bool) {
      throw const FormatException('Invalid read status');
    }
    DateTime? created;
    if (value['created_at'] != null) {
      if (value['created_at'] is! String) {
        throw const FormatException('Invalid timestamp');
      }
      created = DateTime.tryParse(value['created_at'] as String);
      if (created == null) throw const FormatException('Invalid timestamp');
    }
    DateTime? readAt;
    if (value['read_at'] != null) {
      if (value['read_at'] is! String ||
          (readAt = DateTime.tryParse(value['read_at'] as String)) == null) {
        throw const FormatException('Invalid read timestamp');
      }
    }
    final actor = value['actor'];
    if (actor != null && actor is! Map) {
      throw const FormatException('Invalid actor');
    }
    String? actorString(String key) {
      final field = actor is Map ? actor[key] : null;
      if (field != null && field is! String) {
        throw const FormatException('Invalid actor field');
      }
      return field as String?;
    }

    return InboxNotification(
      id: id,
      type: requiredString('type'),
      title: requiredString('title'),
      body: requiredString('body'),
      data: Map.unmodifiable(data),
      isRead: value['is_read'] as bool,
      createdAt: created,
      readAt: readAt,
      actor: actor == null
          ? null
          : NotificationActor(
              username: actorString('username'),
              profileImage: actorString('profile_image'),
              userId: actorString('user_id'),
              role: actorString('role'),
            ),
    );
  }

  static Map<String, dynamic> encode(InboxNotification item) => {
    'id': item.id,
    'type': item.type,
    'title': item.title,
    'body': item.body,
    'data': item.data,
    'is_read': item.isRead,
    'created_at': item.createdAt?.toIso8601String(),
    'read_at': item.readAt?.toIso8601String(),
    'actor': item.actor == null
        ? null
        : {
            'username': item.actor!.username,
            'profile_image': item.actor!.profileImage,
            'user_id': item.actor!.userId,
            'role': item.actor!.role,
          },
  };
  static InboxPage page(dynamic value, {bool isProduction = false}) {
    if (value is! Map ||
        value['notifications'] is! List ||
        value['hasMore'] is! bool ||
        (value['nextCursor'] != null && value['nextCursor'] is! String)) {
      throw const FormatException('Invalid inbox page');
    }
    final cursor = value['nextCursor'] as String?;
    final more = value['hasMore'] as bool;
    if (more && (cursor == null || cursor.isEmpty)) {
      throw const FormatException('Missing cursor');
    }
    final items = (value['notifications'] as List)
        .map(parse)
        .where(
          (item) =>
              item.type != 'chat_message' &&
              !(isProduction && item.type == 'test'),
        )
        .toList();
    return InboxPage(List.unmodifiable(items), cursor, more);
  }
}

class InboxDataSource {
  InboxDataSource(
    this.dio,
    this.sessions, {
    String Function()? language,
    bool Function()? isProduction,
  }) : language = language ?? (() => 'en'),
       isProduction = isProduction ?? (() => false);
  final Dio dio;
  final AuthSessionService sessions;
  final String Function() language;
  final bool Function() isProduction;
  CancelToken _cancel = CancelToken();
  void cancel() {
    _cancel.cancel('Session ended');
    _cancel = CancelToken();
  }

  Future<dynamic> request(
    String path,
    int generation, {
    String method = 'GET',
    Map<String, dynamic>? query,
    bool envelope = true,
  }) async {
    if (sessions.current?.generation != generation) {
      throw StateError('Stale session');
    }
    final lang = language();
    final response = await dio.request(
      path,
      queryParameters: query,
      cancelToken: _cancel,
      options: Options(
        method: method,
        headers: {'Accept-Language': lang == 'ar' ? 'ar' : 'en'},
        extra: {'sessionGeneration': generation},
      ),
    );
    if (sessions.current?.generation != generation) {
      throw StateError('Stale session');
    }
    final json = response.data;
    if (!envelope) return null;
    if (json is! Map || json['data'] is! Map) {
      throw const FormatException('Invalid response envelope');
    }
    return json['data'];
  }
}

class InboxRepositoryImpl implements InboxRepository {
  InboxRepositoryImpl(this.source);
  final InboxDataSource source;
  Future<ApiResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return ApiSuccess(await action());
    } catch (error) {
      if (error is DioException) {
        final status = error.response?.statusCode;
        if (status == 401) {
          return const ApiError(
            UnauthorizedFailure('Sign in again to load notifications.'),
          );
        }
        if (status == 404 &&
            error.response?.data is Map &&
            ((error.response?.data['code'] ?? error.response?.data['error']) ==
                'notification_not_found')) {
          return const ApiError(InboxNotFoundFailure());
        }
        if (status == null || status == 429 || status >= 500) {
          return const ApiError(
            NetworkFailure(
              'Unable to connect. Your saved notifications are available.',
            ),
          );
        }
      }
      return const ApiError(
        ServerFailure('Unable to update notifications. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<InboxPage>> fetch(
    int generation, {
    String? cursor,
    required bool autoRead,
  }) => _guard(
    () async => InboxNotificationModel.page(
      await source.request(
        ApiEndpoints.notifications,
        generation,
        query: {'limit': 20, 'auto_read': autoRead, 'before': ?cursor},
      ),
      isProduction: source.isProduction(),
    ),
  );
  @override
  Future<ApiResult<int>> unread(int generation) => _guard(() async {
    final data = await source.request(
      ApiEndpoints.notificationUnreadCount,
      generation,
    );
    final count = data['unread_count'];
    if (count is! int || count < 0) {
      throw const FormatException('Invalid unread count');
    }
    return count;
  });
  @override
  Future<ApiResult<void>> markRead(String id, int generation) =>
      _guard(() async {
        await source.request(
          ApiEndpoints.notificationRead(Uri.encodeComponent(id)),
          generation,
          method: 'PATCH',
          envelope: false,
        );
      });
  @override
  Future<ApiResult<int>> markAll(int generation) => _guard(() async {
    final data = await source.request(
      ApiEndpoints.notificationReadAll,
      generation,
      method: 'PATCH',
    );
    if (data['updated'] is! int || (data['updated'] as int) < 0) {
      throw const FormatException('Invalid read-all response');
    }
    return data['updated'] as int;
  });
  String _key(String owner) =>
      'notification_inbox_v1_${Uri.encodeComponent(owner)}';
  Future<void> _storage = Future.value();
  Future<void> _serialize(Future<void> Function() action) {
    final next = _storage.then((_) => action());
    _storage = next.catchError((Object _) {});
    return _storage;
  }

  @override
  Future<InboxPage?> cached(String owner) async {
    try {
      await _storage;
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(owner));
      return raw == null
          ? null
          : InboxNotificationModel.page(
              jsonDecode(raw),
              isProduction: source.isProduction(),
            );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cache(String owner, InboxPage page) => _serialize(() async {
    final prefs = await SharedPreferences.getInstance();
    if (source.sessions.current?.userId != owner) return;
    await prefs.setString(
      _key(owner),
      jsonEncode({
        'notifications': page.items.map(InboxNotificationModel.encode).toList(),
        'hasMore': page.hasMore,
        'nextCursor': page.nextCursor,
      }),
    );
  });
  @override
  Future<void> clear(String owner) => _serialize(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(owner));
  });
  @override
  void cancel() => source.cancel();
}
