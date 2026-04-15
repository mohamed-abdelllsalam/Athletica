import 'package:athletica/features/auth/presentation/views/new_password_view.dart';
import 'package:athletica/features/auth/presentation/views/otp_view.dart';
import 'package:athletica/features/auth/presentation/views/reset_password_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_view.dart';
import 'package:athletica/features/chat/presentation/views/chat_view.dart';
import 'package:athletica/features/complete_profile/presentation/views/complete_profile_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:athletica/features/profile/presentation/views/edit_profile_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_view.dart';
import 'package:athletica/features/settings/presentation/views/settings_view.dart';
import 'package:athletica/features/splash/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashView.routeName:
      return MaterialPageRoute(builder: (context) => const SplashView());
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
      return MaterialPageRoute(builder: (context) => const CompleteProfileView());
    case ProfileView.routeName:
      return MaterialPageRoute(builder: (context) => const ProfileView());
    case EditProfileView.routeName:
      return MaterialPageRoute(builder: (context) => const EditProfileView());
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}



