sealed class SplashState {
  const SplashState();
}

final class SplashAnimating extends SplashState {
  const SplashAnimating();
}

final class SplashNavigate extends SplashState {
  final String route;
  const SplashNavigate(this.route);
}
