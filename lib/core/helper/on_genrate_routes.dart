import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/auth/presentation/views/new_password_view.dart';
import 'package:athletica/features/check_ins/presentation/views/check_ins_preview_view.dart';
import 'package:flutter/foundation.dart';
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
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_subscription_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_upload_video_view.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
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
import 'package:athletica/features/workout/presentation/views/workout_history_view.dart';
import 'package:athletica/features/workout/presentation/views/workout_my_plan_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:athletica/features/profile/presentation/views/edit_profile_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_info_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_view.dart';
import 'package:athletica/features/settings/presentation/views/settings_view.dart';
import 'package:athletica/features/splash/presentation/views/splash_view.dart';
import 'package:athletica/features/workout_session/presentation/views/workout_session_view.dart';
import 'package:athletica/features/assigned/presentation/views/assigned_view.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case CheckInsPreviewView.routeName:
      if (!kDebugMode) {
        return MaterialPageRoute(builder: (_) => const SplashView());
      }
      final role = settings.arguments;
      return MaterialPageRoute(
        builder: (_) => CheckInsPreviewView(
          role: role is CheckInPreviewRole ? role : CheckInPreviewRole.coach,
        ),
      );
    case SplashView.routeName:
      return MaterialPageRoute(builder: (context) => const SplashView());
    case CoachHomeView.routeName:
      return MaterialPageRoute(builder: (context) => const CoachHomeView());
    case ClientPlanDetailView.routeName:
      final client = settings.arguments! as CoachPlanClient;
      return MaterialPageRoute(
        builder: (context) => ClientPlanDetailView(client: client),
      );
    case WorkoutPlansListView.routeName:
      return MaterialPageRoute(
        builder: (context) => const WorkoutPlansListView(),
      );
    case NutritionPlansListView.routeName:
      return MaterialPageRoute(
        builder: (context) => const NutritionPlansListView(),
      );
    case AssignPlanTemplatesView.routeName:
      final args = settings.arguments! as Map<String, dynamic>;
      final clientId = args['clientId'] as String;
      return MaterialPageRoute(
        builder: (context) => AssignPlanTemplatesView(clientId: clientId),
      );
    case NutritionPlanDetailView.routeName:
      final plan = settings.arguments;
      if (plan is NutritionPlan) {
        return MaterialPageRoute(
          builder: (context) => NutritionPlanDetailView(plan: plan),
        );
      }
      return MaterialPageRoute(
        builder: (context) => const NutritionPlansListView(),
      );
    case CoachClientsView.routeName:
      return MaterialPageRoute(builder: (context) => const CoachClientsView());
    case CoachActiveClientsView.routeName:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => sl<CoachClientsCubit>()..loadClients(),
          child: const CoachActiveClientsView(),
        ),
      );
    case CoachExpiringSubscriptionsView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachExpiringSubscriptionsView(),
      );
    case CoachJoinRequestsView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachJoinRequestsView(),
      );
    case CoachClientDetailView.routeName:
      final args = settings.arguments! as Map<String, dynamic>;
      final clientId = args['clientId'] as String;
      final clientName = args['clientName'] as String;
      return MaterialPageRoute(
        builder: (context) =>
            CoachClientDetailView(clientId: clientId, clientName: clientName),
      );
    case CoachClientInfoView.routeName:
      final detail = settings.arguments! as ClientDetail;
      return MaterialPageRoute(
        builder: (context) => CoachClientInfoView(detail: detail),
      );
    case CoachMessagesView.routeName:
      return MaterialPageRoute(builder: (context) => const CoachMessagesView());
    case CoachChatView.routeName:
      final contact = settings.arguments! as ChatContact;
      return MaterialPageRoute(
        builder: (context) => CoachChatView(contact: contact),
      );
    case CoachContactProfileView.routeName:
      final contact = settings.arguments! as ChatContact;
      return MaterialPageRoute(
        builder: (context) => CoachContactProfileView(contact: contact),
      );
    case CoachMessageRequestsView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachMessageRequestsView(),
      );
    case CoachProfileView.routeName:
      return MaterialPageRoute(builder: (context) => const CoachProfileView());
    case CoachEditProfileView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachEditProfileView(),
      );
    case CoachProfilePhotoView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachProfilePhotoView(),
      );
    case CoachCompleteProfileView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachCompleteProfileView(),
      );
    case CoachAddCertificateView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachAddCertificateView(),
      );
    case CoachUploadVideoView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachUploadVideoView(),
      );
    case CoachSubscriptionView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachSubscriptionView(),
      );
    case AssignedView.routeName:
      return MaterialPageRoute(builder: (context) => const AssignedView());
    case OnBoardingView.routeName:
      return MaterialPageRoute(builder: (context) => const OnBoardingView());
    case SignInView.routeName:
      return MaterialPageRoute(builder: (context) => const SignInView());
    case RoleSelectionView.routeName:
      return MaterialPageRoute(builder: (context) => const RoleSelectionView());
    case SignUpView.routeName:
      final selectedRole = settings.arguments as String? ?? 'Client';
      return MaterialPageRoute(
        builder: (context) => SignUpView(selectedRole: selectedRole),
      );
    case VerifyYourIdentityView.routeName:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (context) => VerifyYourIdentityView(email: email),
      );
    case SignUpEmailVerificationOtpView.routeName:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (context) => SignUpEmailVerificationOtpView(email: email),
      );
    case ResetPasswordView.routeName:
      return MaterialPageRoute(builder: (context) => const ResetPasswordView());
    case ResetOtpView.routeName:
      final email = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (context) => ResetOtpView(email: email),
      );
    case NewPasswordView.routeName:
      final args = settings.arguments! as ({String email, String code});
      return MaterialPageRoute(
        builder: (context) =>
            NewPasswordView(email: args.email, code: args.code),
      );
    case InfoView.routeName:
      return MaterialPageRoute(builder: (context) => const InfoView());
    case HomeView.routeName:
      return MaterialPageRoute(builder: (context) => const HomeView());
    case ClientCoachView.routeName:
      return MaterialPageRoute(builder: (context) => const ClientCoachView());
    case MyPlanDetailsView.routeName:
      return MaterialPageRoute(builder: (context) => const MyPlanDetailsView());
    case WorkoutMyPlanView.routeName:
      return MaterialPageRoute(builder: (context) => const WorkoutMyPlanView());
    case WorkoutHistoryView.routeName:
      return MaterialPageRoute(builder: (context) => const WorkoutHistoryView());
    case SettingsView.routeName:
      return MaterialPageRoute(builder: (context) => const SettingsView());
    case ChatView.routeName:
      return MaterialPageRoute(builder: (context) => const ChatView());
    case CompleteProfileView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CompleteProfileView(),
      );
    case ProfileView.routeName:
      return MaterialPageRoute(builder: (context) => const ProfileView());
    case EditProfileView.routeName:
      return MaterialPageRoute(builder: (context) => const EditProfileView());
    case ProfileInfoView.routeName:
      return MaterialPageRoute(builder: (context) => const ProfileInfoView());
    case WorkoutSessionView.routeName:
      final args =
          settings.arguments!
              as ({WorkoutExercise exercise, int exerciseIndex});
      return MaterialPageRoute(
        builder: (context) => WorkoutSessionView(
          exercise: args.exercise,
          exerciseIndex: args.exerciseIndex,
        ),
      );
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}
