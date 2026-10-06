import 'dart:async';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/services/auth_session_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import '../entities/inbox_notification.dart';
import '../repositories/inbox_repository.dart';

sealed class InboxSnapshot {
  const factory InboxSnapshot({
    List<InboxNotification> items,
    int unread,
    bool loading,
    bool loadingMore,
    bool reading,
    bool hasMore,
    String? cursor,
    String? error,
    String? badgeError,
    bool connectionError,
    bool badgeConnectionError,
  }) = InboxState;
  const InboxSnapshot._({
    this.items = const [],
    this.unread = 0,
    this.loading = false,
    this.loadingMore = false,
    this.reading = false,
    this.hasMore = false,
    this.cursor,
    this.error,
    this.badgeError,
    this.connectionError = false,
    this.badgeConnectionError = false,
  });
  final List<InboxNotification> items;
  final int unread;
  final bool loading, loadingMore, reading, hasMore;
  final String? cursor, error, badgeError;
  final bool connectionError, badgeConnectionError;
  InboxSnapshot copy({
    List<InboxNotification>? items,
    int? unread,
    bool? loading,
    bool? loadingMore,
    bool? reading,
    bool? hasMore,
    String? cursor,
    String? error,
    String? badgeError,
    bool? connectionError,
    bool? badgeConnectionError,
    bool clearBadgeError = false,
    bool clearCursor = false,
  }) => InboxSnapshot(
    items: items ?? this.items,
    unread: unread ?? this.unread,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    reading: reading ?? this.reading,
    hasMore: hasMore ?? this.hasMore,
    cursor: clearCursor ? null : cursor ?? this.cursor,
    error: error,
    connectionError: error == null
        ? false
        : connectionError ?? this.connectionError,
    badgeConnectionError: clearBadgeError
        ? false
        : badgeConnectionError ?? this.badgeConnectionError,
    badgeError: clearBadgeError ? null : badgeError ?? this.badgeError,
  );
}

final class InboxState extends InboxSnapshot {
  const InboxState({
    super.items = const [],
    super.unread = 0,
    super.loading = false,
    super.loadingMore = false,
    super.reading = false,
    super.hasMore = false,
    super.cursor,
    super.error,
    super.badgeError,
    super.connectionError = false,
    super.badgeConnectionError = false,
  }) : super._();
}

/// Coordinates page reads and badge reconciliation at the authenticated-session
/// boundary. Widgets and background isolates never own this account state.
class NotificationInbox {
  NotificationInbox(this.repository, this.sessions);
  final InboxRepository repository;
  final AuthSessionService sessions;
  final _changes = StreamController<InboxSnapshot>.broadcast(sync: true);
  Stream<InboxSnapshot> get changes => _changes.stream;
  InboxSnapshot state = const InboxSnapshot();
  StreamSubscription<AuthSession?>? _subscription;
  AuthSession? _owner;
  Future<void>? _badge;
  bool _badgeAgain = false;
  int _pageSerial = 0;
  bool _visible = false;
  Future<void> _readTail = Future.value();
  final Map<String, Future<void>> _reads = {};
  final Set<String> _confirmedReads = {};
  final Set<String> _removed = {};
  int _readAllRevision = 0;
  void _emit(InboxSnapshot next) {
    state = next;
    _changes.add(next);
  }

  bool _current(AuthSession owner) =>
      sessions.current?.generation == owner.generation;
  void start() {
    if (_subscription != null) return;
    _subscription = sessions.changes.listen(_switch);
    _switch(sessions.current);
  }

  void _switch(AuthSession? next) {
    final previous = _owner;
    _owner = next;
    ++_pageSerial;
    repository.cancel();
    _badge = null;
    _badgeAgain = false;
    _visible = false;
    _readTail = Future.value();
    _reads.clear();
    _confirmedReads.clear();
    _removed.clear();
    _readAllRevision = 0;
    _emit(const InboxSnapshot());
    if (previous != null) unawaited(repository.clear(previous.userId));
    if (next != null) unawaited(_restore(next));
  }

  Future<void> _restore(AuthSession owner) async {
    final serial = _pageSerial;
    final readAllRevision = _readAllRevision;
    final page = await repository.cached(owner.userId);
    if (!_current(owner)) return;
    if (page != null &&
        serial == _pageSerial &&
        readAllRevision == _readAllRevision) {
      _emit(
        state.copy(
          items: _deduplicate(page.items),
          hasMore: page.hasMore,
          cursor: page.nextCursor,
        ),
      );
    }
    await refreshBadge();
  }

  void setVisible(bool visible) {
    _visible = visible;
  }

  Future<void> refreshBadge() {
    final owner = sessions.current;
    if (owner == null) return Future.value();
    if (_badge != null) {
      _badgeAgain = true;
      return _badge!;
    }
    final operation = _refreshBadge(owner);
    _badge = operation;
    unawaited(
      operation.whenComplete(() {
        if (_current(owner)) _badge = null;
      }),
    );
    return operation;
  }

  Future<void> _refreshBadge(AuthSession owner) async {
    do {
      _badgeAgain = false;
      final result = await repository.unread(owner.generation);
      if (!_current(owner)) return;
      switch (result) {
        case ApiSuccess<int>(:final data):
          _emit(
            state.copy(unread: data, error: state.error, clearBadgeError: true),
          );
        case ApiError<int>(:final failure):
          _emit(
            state.copy(
              error: state.error,
              badgeError: failure.message,
              badgeConnectionError: failure is NetworkFailure,
            ),
          );
      }
    } while (_badgeAgain);
  }

  Future<void> refresh({bool visible = false}) async {
    final owner = sessions.current;
    if (owner == null) return;
    final serial = ++_pageSerial;
    var readAllRevision = _readAllRevision;
    _emit(state.copy(loading: true, loadingMore: false));
    if (state.items.isEmpty) {
      final cached = await repository.cached(owner.userId);
      if (!_current(owner) || serial != _pageSerial) return;
      if (cached != null && readAllRevision == _readAllRevision) {
        _emit(
          state.copy(
            items: _deduplicate(cached.items),
            hasMore: cached.hasMore,
            cursor: cached.nextCursor,
          ),
        );
      }
    }
    readAllRevision = _readAllRevision;
    final autoRead = visible && _visible;
    final result = await repository.fetch(owner.generation, autoRead: autoRead);
    if (!_current(owner) || serial != _pageSerial) return;
    if (result is ApiSuccess<InboxPage> &&
        readAllRevision != _readAllRevision) {
      // A pre-read-all snapshot cannot establish current read state. Keep the
      // confirmed list/cursor so the user can request a fresh page on demand.
      _emit(state.copy(loading: false, error: state.error));
      await refreshBadge();
      return;
    }
    switch (result) {
      case ApiSuccess<InboxPage>(:final data):
        final items = _deduplicate(data.items);
        _emit(
          state.copy(
            items: items,
            loading: false,
            hasMore: data.hasMore,
            cursor: data.nextCursor,
            clearCursor: data.nextCursor == null,
          ),
        );
        await repository.cache(
          owner.userId,
          InboxPage(items, data.nextCursor, data.hasMore),
        );
        if (_current(owner)) await refreshBadge();
      case ApiError<InboxPage>(:final failure):
        _emit(
          state.copy(
            loading: false,
            error: failure.message,
            connectionError: failure is NetworkFailure,
          ),
        );
    }
  }

  Future<void> loadMore() async {
    final owner = sessions.current;
    final cursor = state.cursor;
    if (owner == null ||
        state.loading ||
        state.loadingMore ||
        !state.hasMore ||
        cursor == null) {
      return;
    }
    final serial = _pageSerial;
    final readAllRevision = _readAllRevision;
    _emit(state.copy(loadingMore: true));
    final result = await repository.fetch(
      owner.generation,
      cursor: cursor,
      autoRead: _visible,
    );
    if (!_current(owner) || serial != _pageSerial) return;
    if (result is ApiSuccess<InboxPage> &&
        readAllRevision != _readAllRevision) {
      _emit(state.copy(loadingMore: false, error: state.error));
      await refreshBadge();
      return;
    }
    switch (result) {
      case ApiSuccess<InboxPage>(:final data):
        final items = _deduplicate([...state.items, ...data.items]);
        final more = data.hasMore && data.nextCursor != cursor;
        _emit(
          state.copy(
            items: items,
            loadingMore: false,
            hasMore: more,
            cursor: data.nextCursor,
            clearCursor: data.nextCursor == null,
          ),
        );
        await repository.cache(
          owner.userId,
          InboxPage(items, data.nextCursor, more),
        );
        if (_current(owner)) await refreshBadge();
      case ApiError<InboxPage>(:final failure):
        _emit(
          state.copy(
            loadingMore: false,
            error: failure.message,
            connectionError: failure is NetworkFailure,
          ),
        );
    }
  }

  List<InboxNotification> _deduplicate(List<InboxNotification> items) {
    final merged = <String, InboxNotification>{};
    for (final item in items) {
      if (item.type != 'chat_message' && !_removed.contains(item.id)) {
        merged[item.id] = _confirmedReads.contains(item.id)
            ? item.read()
            : item;
      }
    }
    return List.unmodifiable(merged.values);
  }

  Future<void> _queueRead(
    String key,
    Future<void> Function(AuthSession) action,
  ) {
    final owner = sessions.current;
    if (owner == null) return Future.value();
    final scopedKey = '${owner.generation}:$key';
    final pending = _reads[scopedKey];
    if (pending != null) return pending;
    final operation = _readTail
        .then((_) async {
          if (!_current(owner)) return;
          _emit(state.copy(reading: true, error: state.error));
          await action(owner);
        })
        .whenComplete(() {
          if (!_current(owner)) return;
          _reads.remove(scopedKey);
          _emit(state.copy(reading: _reads.isNotEmpty, error: state.error));
        });
    _reads[scopedKey] = operation;
    _readTail = operation;
    return operation;
  }

  Future<void> markRead(String id) {
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(id)) return Future.value();
    return _queueRead(id, (owner) => _markRead(id, owner));
  }

  Future<void> _markRead(String id, AuthSession owner) async {
    _emit(state.copy(reading: true));
    final result = await repository.markRead(id, owner.generation);
    if (!_current(owner)) return;
    switch (result) {
      case ApiSuccess<void>():
        _confirmedReads.add(id);
        _emit(
          state.copy(
            items: state.items
                .map((item) => item.id == id ? item.read() : item)
                .toList(),
          ),
        );
        await repository.cache(
          owner.userId,
          InboxPage(state.items, state.cursor, state.hasMore),
        );
        if (_current(owner)) await refreshBadge();
      case ApiError<void>(:final failure):
        if (failure is InboxNotFoundFailure) _removed.add(id);
        _emit(
          state.copy(
            items: failure is InboxNotFoundFailure
                ? state.items.where((item) => item.id != id).toList()
                : null,
            error: failure.message,
          ),
        );
        if (failure is InboxNotFoundFailure) {
          await repository.cache(
            owner.userId,
            InboxPage(state.items, state.cursor, state.hasMore),
          );
        }
        if (!_current(owner)) return;
        await refreshBadge();
    }
  }

  Future<void> markAllRead() => _queueRead('*all*', _markAllRead);
  Future<void> _markAllRead(AuthSession owner) async {
    _emit(state.copy(reading: true));
    final result = await repository.markAll(owner.generation);
    if (!_current(owner)) return;
    switch (result) {
      case ApiSuccess<int>():
        ++_readAllRevision;
        _confirmedReads.addAll(state.items.map((item) => item.id));
        _emit(
          state.copy(items: state.items.map((item) => item.read()).toList()),
        );
        await repository.cache(
          owner.userId,
          InboxPage(state.items, state.cursor, state.hasMore),
        );
        if (_current(owner)) await refreshBadge();
      case ApiError<int>(:final failure):
        _emit(state.copy(error: failure.message));
        await refreshBadge();
    }
  }
}
