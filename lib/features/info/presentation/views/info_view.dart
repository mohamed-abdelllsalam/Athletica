import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/info/presentation/cubits/info_cubit.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key});
  static const String routeName = 'info';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InfoCubit>(),
      child: const Scaffold(body: InfoViewBody()),
    );
  }
}
