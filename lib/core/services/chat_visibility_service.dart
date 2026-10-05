import 'dart:async';

/// Tracks the foreground conversation without retaining owners from old sessions.
class ChatVisibilityService {
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  final Map<Object, int> _owners = {};
  int _session = 0;
  Object? _visibleOwner;
  String? _visibleConversationId;

  Stream<void> get changes => _changes.stream;
  String? get visibleConversationId => _visibleConversationId;
  int get sessionGeneration => _session;

  Object createOwner() {
    final owner = Object();
    _owners[owner] = _session;
    return owner;
  }

  void setVisible(Object owner, String? conversationId) {
    if (_owners[owner] != _session) return;
    if (conversationId == null || conversationId.isEmpty) {
      clear(owner);
      return;
    }
    if (identical(_visibleOwner, owner) &&
        _visibleConversationId == conversationId) {
      return;
    }
    _visibleOwner = owner;
    _visibleConversationId = conversationId;
    _changes.add(null);
  }

  void clear(Object owner) {
    if (!identical(_visibleOwner, owner)) return;
    _visibleOwner = null;
    _visibleConversationId = null;
    _changes.add(null);
  }

  void release(Object owner) {
    clear(owner);
    _owners.remove(owner);
  }

  /// Call before clearing authentication or changing the authenticated account.
  void resetSession() {
    _session++;
    _owners.clear();
    _visibleOwner = null;
    _visibleConversationId = null;
    _changes.add(null);
  }
}
