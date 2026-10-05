import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/helper/app_navigator_key.dart';
import 'package:athletica/core/helper/on_genrate_routes.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/widgets/refresh_on_focus.dart';
import 'package:athletica/features/notifications/presentation/push_coordinator.dart';
import 'package:athletica/features/splash/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AthleticaApp extends StatelessWidget {
  const AthleticaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        navigatorObservers: [
          appRouteObserver,
          if (sl.isRegistered<PushCoordinator>()) PushNavigatorObserver(sl()),
        ],
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.primaryAppColor,
          canvasColor: AppColors.primaryAppColor,
          colorScheme: const ColorScheme.dark(
            surface: AppColors.primaryAppColor,
          ),
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: onGenerateRoute,
        home: const SplashView(),
      ),
    );
  }
}
