import 'package:athletica/features/coach/complete_profile/presentation/cubits/add_certificate_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_add_certificate_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachAddCertificateView extends StatelessWidget {
  const CoachAddCertificateView({super.key});

  static const String routeName = 'coach-add-certificate';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCertificateCubit(),
      child: const CoachAddCertificateViewBody(),
    );
  }
}
