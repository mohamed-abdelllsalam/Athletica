import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/services/auth_session_service.dart';
import 'package:athletica/features/notifications/presentation/views/notification_inbox_view.dart';
import 'package:athletica/features/notifications/presentation/cubits/notification_inbox_cubit.dart';
import 'package:athletica/features/notifications/presentation/push_coordinator.dart';
import 'package:athletica/features/achievements/domain/entities/coach_achievement.dart';
import 'package:athletica/features/auth/presentation/views/new_password_view.dart';
import 'package:athletica/features/check_ins/presentation/models/check_in_preview_role.dart';
import 'package:athletica/features/check_ins/presentation/views/check_ins_preview_view.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/coach_clients_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:athletica/features/auth/presentation/views/reset_otp_view.dart';
import 'package:athletica/features/auth/presentation/views/reset_password_view.dart';
import 'package:athletica/features/auth/presentation/views/role_selection_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_email_verification_otp_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_view.dart';
import 'package:athletica/features/auth/presentation/views/verify_your_identity_view.dart';
import 'package:athletica/features/chat/presentation/views/chat_view.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_active_clients_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_detail_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_info_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_clients_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_expiring_subscriptions_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_join_requests_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_add_certificate_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_complete_profile_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_certificate_review_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_subscription_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_upload_video_view.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/models/coach_chat_route_args.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_contact_profile_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_message_requests_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_messages_view.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_plan_client.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/client_plan_detail_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/assign_plan_templates_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_plan_detail_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/nutrition_plans_list_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_plans_list_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_edit_profile_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_photo_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_view.dart';
import 'package:athletica/features/complete_profile/presentation/views/complete_profile_view.dart';
import 'package:athletica/features/client_coach/presentation/views/client_coach_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:athletica/features/nutrition/presentation/views/my_plan_details_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:athletica/features/profile/presentation/views/edit_profile_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_info_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_view.dart';
import 'package:athletica/features/settings/presentation/views/settings_view.dart';
import 'package:athletica/features/splash/presentation/views/splash_view.dart';
import 'package:athletica/features/workout/presentation/views/todays_workout_view.dart';
import 'package:athletica/features/workout/presentation/views/workout_my_plan_view.dart';
import 'package:athletica/features/workout_session/presentation/views/workout_session_view.dart';
import 'package:athletica/features/assigned/presentation/views/assigned_view.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case NotificationInboxView.routeName:
      final owner = sl<AuthSessionService>().current?.userId;
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => BlocProvider(
          create: (_) => sl<NotificationInboxCubit>(),
          child: NotificationInboxView(
            onTap: (item) {
              if (owner != null) {
                sl<PushCoordinator>().inboxTap(item, owner: owner);
              }
            },
          ),
        ),
      );
    case CheckInsPreviewView.routeName:
      final role = settings.arguments;
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => CheckInsPreviewView(
          role: role is CheckInPreviewRole ? role : CheckInPreviewRole.coach,
        ),
      );
    case SplashView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SplashView(),
      );
    case CoachHomeView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachHomeView(),
      );
    case ClientPlanDetailView.routeName:
      final client = settings.arguments! as CoachPlanClient;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => ClientPlanDetailView(client: client),
      );
    case WorkoutPlansListView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const WorkoutPlansListView(),
      );
    case NutritionPlansListView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const NutritionPlansListView(),
      );
    case AssignPlanTemplatesView.routeName:
      final args = settings.arguments! as Map<String, dynamic>;
      final clientId = args['clientId'] as String;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => AssignPlanTemplatesView(clientId: clientId),
      );
    case NutritionPlanDetailView.routeName:
      final plan = settings.arguments;
      if (plan is NutritionPlan) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => NutritionPlanDetailView(plan: plan),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const NutritionPlansListView(),
      );
    case CoachClientsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachClientsView(),
      );
    case CoachActiveClientsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => BlocProvider(
          create: (_) => sl<CoachClientsCubit>()..loadClients(),
          child: const CoachActiveClientsView(),
        ),
      );
    case CoachExpiringSubscriptionsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachExpiringSubscriptionsView(),
      );
    case CoachJoinRequestsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachJoinRequestsView(),
      );
    case CoachClientDetailView.routeName:
      final args = settings.arguments! as Map<String, dynamic>;
      final clientId = args['clientId'] as String;
      final clientName = args['clientName'] as String;
      final coachClientId = args['coachClientId'] as String?;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => CoachClientDetailView(
          clientId: clientId,
          clientName: clientName,
          coachClientId: coachClientId,
        ),
      );
    case CoachClientInfoView.routeName:
      final detail = settings.arguments! as ClientDetail;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => CoachClientInfoView(detail: detail),
      );
    case CoachMessagesView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachMessagesView(),
      );
    case CoachChatView.routeName:
      final args = settings.arguments!;
      if (args is CoachChatRouteArgs) {
        final contact = ChatContact(id: args.clientId, name: args.clientName);
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => CoachChatView(contact: contact, chatArgs: args),
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => CoachChatView(contact: args as ChatContact),
      );
    case CoachContactProfileView.routeName:
      final contact = settings.arguments! as ChatContact;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => CoachContactProfileView(contact: contact),
      );
    case CoachMessageRequestsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachMessageRequestsView(),
      );
    case CoachProfileView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachProfileView(),
      );
    case CoachEditProfileView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachEditProfileView(),
      );
    case CoachProfilePhotoView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachProfilePhotoView(),
      );
    case CoachCompleteProfileView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachCompleteProfileView(),
      );
    case CoachAddCertificateView.routeName:
      return MaterialPageRoute<CoachAchievement>(
        builder: (context) => const CoachAddCertificateView(),
      );
    case CoachCertificateReviewView.routeName:
      final certificates = settings.arguments! as List<CoachAchievement>;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) =>
            CoachCertificateReviewView(certificates: certificates),
      );
    case CoachUploadVideoView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachUploadVideoView(),
      );
    case CoachSubscriptionView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CoachSubscriptionView(),
      );
    case AssignedView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AssignedView(),
      );
    case OnBoardingView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OnBoardingView(),
      );
    case SignInView.routeName:
      final signInArgs = settings.arguments;
      final sessionExpired =
          signInArgs is Map && signInArgs['sessionExpired'] == true;
      final completeProfileAfterLogin =
          signInArgs is Map && signInArgs['completeProfileAfterLogin'] == true;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => SignInView(
          sessionExpired: sessionExpired,
          completeProfileAfterLogin: completeProfileAfterLogin,
        ),
      );
    case RoleSelectionView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const RoleSelectionView(),
      );
    case SignUpView.routeName:
      final selectedRole = settings.arguments as String? ?? 'Client';
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => SignUpView(selectedRole: selectedRole),
      );
    case VerifyYourIdentityView.routeName:
      final args = _signupFlowArgs(settings.arguments);
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => VerifyYourIdentityView(
          email: args.email,
          isNewCoach: args.isNewCoach,
        ),
      );
    case SignUpEmailVerificationOtpView.routeName:
      final args = _signupFlowArgs(settings.arguments);
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => SignUpEmailVerificationOtpView(
          email: args.email,
          isNewCoach: args.isNewCoach,
        ),
      );
    case ResetPasswordView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ResetPasswordView(),
      );
    case ResetOtpView.routeName:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => ResetOtpView(email: email),
      );
    case NewPasswordView.routeName:
      final args = settings.arguments! as ({String email, String code});
      return MaterialPageRoute(
        settings: settings,
        builder: (context) =>
            NewPasswordView(email: args.email, code: args.code),
      );
    case InfoView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const InfoView(),
      );
    case HomeView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const HomeView(),
      );
    case WorkoutMyPlanView.routeName:
      final args = settings.arguments;
      final typedArgs = args is WorkoutMyPlanRouteArgs
          ? args
          : const WorkoutMyPlanRouteArgs();
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => WorkoutMyPlanView(
          initialDayNumber: typedArgs.initialDayNumber,
          userGender: typedArgs.userGender,
        ),
      );
    case TodaysWorkoutView.routeName:
      final args = settings.arguments;
      final typedArgs = args is TodaysWorkoutRouteArgs
          ? args
          : const TodaysWorkoutRouteArgs();
      return MaterialPageRoute(
        settings: settings,
        builder: (context) =>
            TodaysWorkoutView(userGender: typedArgs.userGender),
      );
    case ClientCoachView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ClientCoachView(),
      );
    case MyPlanDetailsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const MyPlanDetailsView(),
      );
    case SettingsView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SettingsView(),
      );
    case ChatView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ChatView(),
      );
    case CompleteProfileView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CompleteProfileView(),
      );
    case ProfileView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ProfileView(),
      );
    case EditProfileView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const EditProfileView(),
      );
    case ProfileInfoView.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ProfileInfoView(),
      );
    case WorkoutSessionView.routeName:
      final args =
          settings.arguments!
              as ({WorkoutExercise exercise, int exerciseIndex});
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => WorkoutSessionView(
          exercise: args.exercise,
          exerciseIndex: args.exerciseIndex,
        ),
      );
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const Scaffold(),
      );
  }
}

/// Parses the signup-flow route arguments. The signup flow passes a record
/// `({String email, bool isNewCoach})`; the login flow (email verification
/// required) passes a plain email string.
({String email, bool isNewCoach}) _signupFlowArgs(Object? arguments) {
  if (arguments is ({String email, bool isNewCoach})) {
    return arguments;
  }
  if (arguments is String) {
    return (email: arguments, isNewCoach: false);
  }
  return (email: '', isNewCoach: false);
}
