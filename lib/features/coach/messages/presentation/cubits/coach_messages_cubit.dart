import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/conversation.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_conversations_usecase.dart';
import 'package:athletica/features/coach/messages/domain/entities/coach_message_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CoachMessagesState {
  const CoachMessagesState();
}

final class CoachMessagesLoading extends CoachMessagesState {
  const CoachMessagesLoading();
}

final class CoachMessagesLoaded extends CoachMessagesState {
  const CoachMessagesLoaded(this.messages);
  final List<CoachMessagePreview> messages;
}

final class CoachMessagesFailure extends CoachMessagesState {
  const CoachMessagesFailure(this.message);
  final String message;
}

class CoachMessagesCubit extends Cubit<CoachMessagesState> {
  CoachMessagesCubit(this._getConversations)
    : super(const CoachMessagesLoading());

  final GetChatConversationsUseCase _getConversations;

  Future<void> load() async {
    emit(const CoachMessagesLoading());
    final conversationsResult = await _getConversations();
    if (isClosed) return;
    if (conversationsResult case ApiError(:final failure)) {
      emit(CoachMessagesFailure(failure.message));
      return;
    }
    final conversations =
        (conversationsResult as ApiSuccess<List<Conversation>>).data;
    final previews = conversations
        .map((conversation) {
          final counterpart = conversation.counterpart;
          final username = counterpart?.username?.trim();
          final clientId = counterpart?.id ?? conversation.clientId;
          return CoachMessagePreview(
            id: clientId,
            name: username?.isNotEmpty == true ? username! : 'Client',
            preview: conversation.lastMessage?.previewText ?? '',
            timeAgo: _timeAgo(conversation.lastMessageAt),
            imageUrl: counterpart?.profileImage,
            conversationId: conversation.id,
            coachClientId: conversation.coachClientId,
            clientId: clientId,
          );
        })
        .toList(growable: false);
    if (!isClosed) emit(CoachMessagesLoaded(previews));
  }

  String _timeAgo(DateTime? value) {
    if (value == null) return '';
    final elapsed = DateTime.now().difference(value.toLocal());
    if (elapsed.inMinutes < 1) return 'now';
    if (elapsed.inHours < 1) return '${elapsed.inMinutes} m';
    if (elapsed.inDays < 1) return '${elapsed.inHours} h';
    if (elapsed.inDays < 7) return '${elapsed.inDays} d';
    return '${value.toLocal().month}/${value.toLocal().day}';
  }
}
