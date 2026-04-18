import 'package:athletica/features/auth/presentation/views/new_password_view.dart';
import 'package:athletica/features/auth/presentation/views/otp_view.dart';
import 'package:athletica/features/auth/presentation/views/reset_password_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_view.dart';
import 'package:athletica/features/chat/presentation/views/chat_view.dart';
import 'package:athletica/features/coach/clients/domain/entities/coach_client.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_contact_profile_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_message_requests_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_detail_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_clients_view.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_join_requests_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_add_certificate_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_complete_profile_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_subscription_view.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/coach_upload_video_view.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_messages_view.dart';
import 'package:athletica/features/coach/plan/domain/entities/coach_plan_client.dart';
import 'package:athletica/features/coach/plan/presentation/views/client_plan_detail_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_plans_list_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_edit_profile_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_photo_view.dart';
import 'package:athletica/features/coach/profile/presentation/views/coach_profile_view.dart';
import 'package:athletica/features/complete_profile/presentation/views/complete_profile_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:athletica/features/profile/presentation/views/edit_profile_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_view.dart';
import 'package:athletica/features/settings/presentation/views/settings_view.dart';
import 'package:athletica/features/splash/presentation/views/splash_view.dart';
import 'package:athletica/features/workout_session/presentation/views/workout_session_view.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
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
    case CoachClientsView.routeName:
      return MaterialPageRoute(builder: (context) => const CoachClientsView());
    case CoachJoinRequestsView.routeName:
      return MaterialPageRoute(
        builder: (context) => const CoachJoinRequestsView(),
      );
    case CoachClientDetailView.routeName:
      final client = settings.arguments! as CoachClient;
      return MaterialPageRoute(
        builder: (context) => CoachClientDetailView(client: client),
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
    case OnBoardingView.routeName:
      return MaterialPageRoute(builder: (context) => const OnBoardingView());
    case SignInView.routeName:
      return MaterialPageRoute(builder: (context) => const SignInView());
    case SignUpView.routeName:
      return MaterialPageRoute(builder: (context) => const SignUpView());
    case ResetPasswordView.routeName:
      return MaterialPageRoute(builder: (context) => const ResetPasswordView());
    case OtpView.routeName:
      return MaterialPageRoute(builder: (context) => const OtpView());
    case NewPasswordView.routeName:
      return MaterialPageRoute(builder: (context) => const NewPasswordView());
    case InfoView.routeName:
      return MaterialPageRoute(builder: (context) => const InfoView());
    case HomeView.routeName:
      return MaterialPageRoute(builder: (context) => const HomeView());
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
