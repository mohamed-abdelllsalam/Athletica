class NotificationActor {
  const NotificationActor({
    this.username,
    this.profileImage,
    this.userId,
    this.role,
  });
  final String? username;
  final String? profileImage;
  final String? userId, role;
}

class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.actor,
  });
  final String id, type, title, body;
  final Map<String, String> data;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;
  final NotificationActor? actor;
  InboxNotification read() => InboxNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    data: data,
    isRead: true,
    createdAt: createdAt,
    readAt: readAt,
    actor: actor,
  );
}

class InboxPage {
  const InboxPage(this.items, this.nextCursor, this.hasMore);
  final List<InboxNotification> items;
  final String? nextCursor;
  final bool hasMore;
}
