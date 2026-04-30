import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const String routeName = 'homeView';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    sl<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProfileCubit>(),
      child: const Scaffold(body: HomeViewBody()),
    );
  }
}
