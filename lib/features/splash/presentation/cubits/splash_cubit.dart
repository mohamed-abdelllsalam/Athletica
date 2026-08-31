import 'package:athletica/features/auth/domain/entities/auth_status.dart';
import 'package:athletica/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/on_boarding/presentation/views/on_boarding_view.dart';
import 'package:athletica/features/splash/presentation/cubits/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<SplashState> {
  final CheckAuthStatusUseCase _checkAuthStatus;

  SplashCubit(this._checkAuthStatus) : super(const SplashAnimating());

  Future<void> checkStatus() async {
    final status = await _checkAuthStatus();
    final route = switch (status) {
      Unauthenticated() => OnBoardingView.routeName,
      ClientProfileIncomplete() => HomeView.routeName,
      CoachProfileIncomplete() => CoachHomeView.routeName,
      ClientReady() => HomeView.routeName,
      CoachReady() => CoachHomeView.routeName,
    };
    if (isClosed) return;
    emit(SplashNavigate(route));
  }
}
