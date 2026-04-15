import 'package:athletica/features/auth/presentation/views/new_password_view.dart';
import 'package:athletica/features/auth/presentation/views/otp_view.dart';
import 'package:athletica/features/auth/presentation/views/reset_password_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_in_view.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/presentation/views/info_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
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
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}

