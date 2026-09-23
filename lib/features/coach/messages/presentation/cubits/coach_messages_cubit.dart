import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/conversation.dart';
import 'package:athletica/features/chat/domain/entities/chat_history_page.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_conversations_usecase.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_assigned_client.dart';
import 'package:athletica/features/coach/clients/domain/usecases/get_coach_assigned_clients_usecase.dart';
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
  CoachMessagesCubit(
    this._getConversations,
    this._getHistory,
    this._getAssignedClients,
  ) : super(const CoachMessagesLoading());

  final GetChatConversationsUseCase _getConversations;
  final GetChatHistoryUseCase _getHistory;
  final GetCoachAssignedClientsUseCase _getAssignedClients;

  Future<void> load() async {
    emit(const CoachMessagesLoading());
    final conversationsResult = await _getConversations();
    final clientsResult = await _getAssignedClients();
    if (isClosed) return;
    if (conversationsResult case ApiError(:final failure)) {
      emit(CoachMessagesFailure(failure.message));
      return;
    }
    if (clientsResult case ApiError(:final failure)) {
      emit(CoachMessagesFailure(failure.message));
      return;
    }
    final conversations =
        (conversationsResult as ApiSuccess<List<Conversation>>).data;
    final clients =
        (clientsResult as ApiSuccess<List<CoachAssignedClient>>).data;
    final clientByRelation = {
      for (final client in clients) client.relationId: client,
    };
    final previews = <CoachMessagePreview>[];
    for (var start = 0; start < conversations.length; start += 5) {
      final batch = conversations.skip(start).take(5).toList();
      final histories = await Future.wait(
        batch.map(
          (conversation) =>
              _getHistory(conversationId: conversation.id, limit: 1),
        ),
      );
      if (isClosed) return;
      for (var index = 0; index < batch.length; index++) {
        final conversation = batch[index];
        final assignment = clientByRelation[conversation.coachClientId];
        final history = histories[index];
        final latest = switch (history) {
          ApiSuccess<ChatHistoryPage>(:final data)
              when data.messages.isNotEmpty =>
            data.messages.first,
          _ => null,
        };
        previews.add(
          CoachMessagePreview(
            id: assignment?.clientId ?? conversation.clientId,
            name: assignment?.name.isNotEmpty == true
                ? assignment!.name
                : 'Client',
            preview: latest?.content ?? '',
            timeAgo: _timeAgo(conversation.lastMessageAt),
            imageUrl: assignment?.profileImage,
            conversationId: conversation.id,
            coachClientId: conversation.coachClientId,
            clientId: assignment?.clientId ?? conversation.clientId,
          ),
        );
      }
    }
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
