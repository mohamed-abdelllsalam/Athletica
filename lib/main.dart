import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/helper/on_genrate_routes.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/features/splash/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const Athletica());
}

class Athletica extends StatelessWidget {
  const Athletica({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: AppColors.primaryAppColor),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: onGenerateRoute,
        home: const SplashView(),
      ),
    );
  }
}
