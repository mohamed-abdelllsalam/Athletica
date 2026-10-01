import 'package:flutter/material.dart';

/// Keeps the visible message in place when a reversed chat gets newer items.
class ChatScrollAnchor {
  final Map<String, GlobalKey> _messageKeys = {};

  GlobalKey keyFor(String id) => _messageKeys.putIfAbsent(id, GlobalKey.new);

  void retainMessages(Iterable<String> ids) {
    final retained = ids.toSet();
    _messageKeys.removeWhere((id, _) => !retained.contains(id));
  }

  VoidCallback? capture(
    ScrollController controller,
    bool Function() isMounted,
  ) {
    if (!controller.hasClients) return null;
    final viewport = controller.position.context.notificationContext
        ?.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) return null;
    final top = viewport.localToGlobal(Offset.zero).dy;
    final bottom = top + viewport.size.height;
    for (final key in _messageKeys.values) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final oldY = box.localToGlobal(Offset.zero).dy;
      if (oldY >= bottom || oldY + box.size.height <= top) continue;
      return () {
        if (!isMounted() || !controller.hasClients) return;
        final updated = key.currentContext?.findRenderObject();
        if (updated is! RenderBox || !updated.hasSize) return;
        final newY = updated.localToGlobal(Offset.zero).dy;
        final position = controller.position;
        final target = position.pixels + oldY - newY;
        controller.jumpTo(
          target
              .clamp(position.minScrollExtent, position.maxScrollExtent)
              .toDouble(),
        );
      };
    }
    return null;
  }
}
