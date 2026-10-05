import 'dart:async';
import 'package:athletica/features/chat/presentation/models/chat_route_args.dart';
import 'package:athletica/features/chat/presentation/views/chat_view.dart';
import 'package:athletica/features/check_ins/presentation/models/check_in_preview_role.dart';
import 'package:athletica/features/check_ins/presentation/views/check_ins_preview_view.dart';
import 'package:athletica/features/client_coach/presentation/views/client_coach_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_join_requests_view.dart';
import 'package:athletica/features/coach/messages/presentation/models/coach_chat_route_args.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_messages_view.dart';
import 'package:athletica/features/notifications/domain/entities/notification_payload.dart';
import 'package:athletica/features/notifications/domain/usecases/resolve_notification_destination.dart';
import 'package:athletica/features/nutrition/presentation/views/my_plan_details_view.dart';
import 'package:athletica/features/workout/presentation/views/workout_my_plan_view.dart';
import 'package:flutter/material.dart';

class NotificationRouter {
  const NotificationRouter(this._navigatorKey, this._resolve);
  final GlobalKey<NavigatorState> _navigatorKey;
  final ResolveNotificationDestination _resolve;

  Future<bool> route(
    NotificationPayload payload, {
    required String userId,
    required String role,
    required bool Function() isSessionCurrent,
    VoidCallback? onClosed,
  }) async {
    final destination = await _resolve(payload, userId: userId, role: role);
    final navigator = _navigatorKey.currentState;
    if (destination == null || navigator == null || !isSessionCurrent()) {
      return false;
    }
    if (destination.kind == NotificationDestinationKind.clientWorkoutPlan ||
        destination.kind == NotificationDestinationKind.clientNutritionPlan) {
      unawaited(
        navigator
            .push<void>(
              MaterialPageRoute<void>(
                settings: RouteSettings(
                  name: '${destination.kind.name}/${destination.resourceId}',
                ),
                builder: (_) =>
                    destination.kind ==
                        NotificationDestinationKind.clientWorkoutPlan
                    ? WorkoutMyPlanView(planId: destination.resourceId)
                    : MyPlanDetailsView(planId: destination.resourceId),
              ),
            )
            .then((_) {
              onClosed?.call();
            }),
      );
      return true;
    }
    final (route, arguments) = switch (destination.kind) {
      NotificationDestinationKind.coachRequests => (
        CoachJoinRequestsView.routeName,
        null,
      ),
      NotificationDestinationKind.clientCoach ||
      NotificationDestinationKind.clientChatFallback => (
        ClientCoachView.routeName,
        null,
      ),
      NotificationDestinationKind.clientWorkout => (
        WorkoutMyPlanView.routeName,
        null,
      ),
      NotificationDestinationKind.clientNutrition => (
        MyPlanDetailsView.routeName,
        null,
      ),
      NotificationDestinationKind.clientCheckins => (
        CheckInsPreviewView.routeName,
        CheckInPreviewRole.client,
      ),
      NotificationDestinationKind.coachCheckins => (
        CheckInsPreviewView.routeName,
        CheckInPreviewRole.coach,
      ),
      NotificationDestinationKind.coachMessages => (
        CoachMessagesView.routeName,
        null,
      ),
      NotificationDestinationKind.chat => _chatRoute(destination, role),
      NotificationDestinationKind.clientWorkoutPlan ||
      NotificationDestinationKind.clientNutritionPlan => throw StateError(
        'Handled above',
      ),
    };
    // Do not await pop: dispatch completion lets the tap coordinator dedupe.
    unawaited(
      navigator.pushNamed<void>(route, arguments: arguments).then((_) {
        onClosed?.call();
      }),
    );
    return true;
  }

  (String, Object) _chatRoute(
    NotificationDestination destination,
    String role,
  ) {
    final conversation = destination.conversation!;
    final counterpart = conversation.counterpart;
    final name = counterpart?.username?.trim();
    final title = name == null || name.isEmpty
        ? (role == 'coach' ? 'Client' : 'Coach')
        : name;
    if (role == 'coach') {
      return (
        CoachChatView.routeName,
        CoachChatRouteArgs(
          clientId: conversation.clientId,
          clientName: title,
          clientImageUrl: counterpart?.profileImage,
          conversationId: conversation.id,
          coachClientId: conversation.coachClientId,
        ),
      );
    }
    return (
      ChatView.routeName,
      ChatRouteArgs(
        title: title,
        conversationId: conversation.id,
        coachClientId: conversation.coachClientId,
        clientId: conversation.clientId,
      ),
    );
  }
}
