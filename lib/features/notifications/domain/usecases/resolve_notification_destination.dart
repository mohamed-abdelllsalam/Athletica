import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/features/chat/domain/entities/conversation.dart';
import 'package:athletica/features/chat/domain/usecases/get_chat_conversations_usecase.dart';
import 'package:athletica/features/notifications/domain/entities/notification_payload.dart';
import 'package:athletica/features/workout/domain/usecases/get_my_workout_plan_details_usecase.dart';
import 'package:athletica/features/nutrition/domain/usecases/get_my_plan_details_usecase.dart';

enum NotificationDestinationKind {
  coachRequests,
  clientCoach,
  clientWorkout,
  clientWorkoutPlan,
  clientNutrition,
  clientNutritionPlan,
  clientCheckins,
  coachCheckins,
  coachMessages,
  clientChatFallback,
  chat,
}

class NotificationDestination {
  const NotificationDestination(
    this.kind, {
    this.conversation,
    this.resourceId,
  });
  final NotificationDestinationKind kind;
  final Conversation? conversation;
  final String? resourceId;
}

class ResolveNotificationDestination {
  const ResolveNotificationDestination(
    this._getConversations, {
    GetMyWorkoutPlanDetailsUseCase? getWorkoutPlan,
    GetMyPlanDetailsUseCase? getNutritionPlan,
  }) : _getWorkoutPlan = getWorkoutPlan,
       _getNutritionPlan = getNutritionPlan;
  final GetChatConversationsUseCase _getConversations;
  final GetMyWorkoutPlanDetailsUseCase? _getWorkoutPlan;
  final GetMyPlanDetailsUseCase? _getNutritionPlan;

  Future<NotificationDestination?> call(
    NotificationPayload payload, {
    required String userId,
    required String role,
  }) async {
    if (userId.isEmpty || !const {'coach', 'client'}.contains(role)) {
      return null;
    }
    final requiredRole = payload.type.recipientRole;
    if (requiredRole != null && requiredRole != role) return null;
    // These authenticated client APIs enforce resource ownership. Never use
    // the coach plan API to resolve a client notification.
    if (payload.type == NotificationType.workoutAssigned &&
        _getWorkoutPlan != null) {
      final result = await _getWorkoutPlan(payload.resourceId);
      if (result case ApiSuccess(:final data)) {
        if (data.id == payload.resourceId && data.deletedAt == null) {
          return NotificationDestination(
            NotificationDestinationKind.clientWorkoutPlan,
            resourceId: data.id,
          );
        }
      }
    }
    if (payload.type == NotificationType.nutritionAssigned &&
        _getNutritionPlan != null) {
      final result = await _getNutritionPlan(payload.resourceId);
      if (result case ApiSuccess(:final data)) {
        if (data.id == payload.resourceId) {
          return NotificationDestination(
            NotificationDestinationKind.clientNutritionPlan,
            resourceId: data.id,
          );
        }
      }
    }
    if (payload.type != NotificationType.chatMessage) {
      return NotificationDestination(switch (payload.type) {
        NotificationType.coachRequest =>
          NotificationDestinationKind.coachRequests,
        NotificationType.requestAccepted =>
          NotificationDestinationKind.clientCoach,
        NotificationType.workoutAssigned =>
          NotificationDestinationKind.clientWorkout,
        NotificationType.nutritionAssigned =>
          NotificationDestinationKind.clientNutrition,
        NotificationType.checkinRequested =>
          NotificationDestinationKind.clientCheckins,
        NotificationType.checkinSubmitted =>
          NotificationDestinationKind.coachCheckins,
        NotificationType.chatMessage => throw StateError('Handled below'),
      });
    }
    if (payload.senderRole == role) return null;
    final result = await _getConversations();
    if (result is ApiSuccess<List<Conversation>>) {
      for (final conversation in result.data) {
        // Membership in this authenticated API response verifies access.
        // Participant profile IDs are not the login account's user ID.
        if (conversation.id == payload.resourceId &&
            conversation.clientId.isNotEmpty &&
            conversation.coachId.isNotEmpty) {
          return NotificationDestination(
            NotificationDestinationKind.chat,
            conversation: conversation,
          );
        }
      }
    }
    // There is no supported conversation-by-id API or pagination cursor.
    // Never open an unverified conversation using the incoming identifier.
    return NotificationDestination(
      role == 'coach'
          ? NotificationDestinationKind.coachMessages
          : NotificationDestinationKind.clientChatFallback,
    );
  }
}
