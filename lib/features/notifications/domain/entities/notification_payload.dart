enum NotificationType {
  coachRequest('coach_request', 'requestId', 'coach'),
  requestAccepted('request_accepted', 'assignmentId', 'client'),
  workoutAssigned('workout_assigned', 'planId', 'client'),
  nutritionAssigned('nutrition_assigned', 'planId', 'client'),
  checkinRequested('checkin_requested', 'assignmentId', 'client'),
  checkinSubmitted('checkin_submitted', 'submissionId', 'coach'),
  chatMessage('chat_message', 'conversationId', null);

  const NotificationType(this.value, this.idKey, this.recipientRole);
  final String value;
  final String idKey;
  final String? recipientRole;
}

/// Only validated routing identifiers, never server notification copy.
class NotificationPayload {
  const NotificationPayload({
    required this.type,
    required this.resourceId,
    this.messageId,
    this.messageType,
    this.senderRole,
    this.notificationId,
  });

  final NotificationType type;
  final String resourceId;
  final String? messageId;
  final String? messageType;
  final String? senderRole;
  final String? notificationId;

  String get tapKey =>
      '${type.value}:$resourceId:${notificationId ?? messageId ?? ''}';
  String? get conversationId =>
      type == NotificationType.chatMessage ? resourceId : null;

  static NotificationPayload? tryParse(Map<String, dynamic> data) {
    NotificationType? type;
    for (final candidate in NotificationType.values) {
      if (data['type'] == candidate.value) type = candidate;
    }
    if (type == null) return null;
    final id = _identifier(data[type.idKey]);
    if (id == null) return null;
    if (type != NotificationType.chatMessage) {
      final notificationId = _identifier(data['notificationId']);
      if (data.containsKey('notificationId') && notificationId == null) {
        return null;
      }
      return NotificationPayload(
        type: type,
        resourceId: id,
        notificationId: notificationId,
      );
    }
    final messageId = _identifier(data['messageId']);
    final messageType = data['messageType'];
    final senderRole = data['senderRole'];
    if (messageId == null ||
        messageType is! String ||
        !const {'text', 'image', 'voice'}.contains(messageType) ||
        !const {'coach', 'client'}.contains(senderRole)) {
      return null;
    }
    return NotificationPayload(
      type: type,
      resourceId: id,
      messageId: messageId,
      messageType: messageType,
      senderRole: senderRole as String,
    );
  }

  static String? _identifier(Object? value) {
    if (value is! String || value.isEmpty || value.length > 128) return null;
    return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value) ? value : null;
  }
}
