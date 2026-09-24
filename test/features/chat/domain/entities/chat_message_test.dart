import 'package:athletica/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage.chronological', () {
    test('returns newest-first input in oldest-first order', () {
      final newest = _message(id: '3', createdAt: DateTime(2025, 1, 3));
      final middle = _message(id: '2', createdAt: DateTime(2025, 1, 2));
      final oldest = _message(id: '1', createdAt: DateTime(2025, 1, 1));
      final newestFirst = [newest, middle, oldest];

      final result = ChatMessage.chronological(newestFirst);

      expect(result, [oldest, middle, newest]);
      expect(newestFirst, [newest, middle, oldest]);
    });

    test('orders equal timestamps by ascending message id', () {
      final laterId = _message(id: 'message-b', createdAt: DateTime(2025));
      final earlierId = _message(id: 'message-a', createdAt: DateTime(2025));

      final result = ChatMessage.chronological([laterId, earlierId]);

      expect(result, [earlierId, laterId]);
    });
  });
}

ChatMessage _message({required String id, required DateTime createdAt}) =>
    ChatMessage(
      id: id,
      conversationId: 'conversation-1',
      senderUserId: 'user-1',
      senderRole: 'client',
      content: id,
      createdAt: createdAt,
    );
