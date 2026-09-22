import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/models/check_in_preview_role.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/check_in_coach_list.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/client_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckInsPreviewView extends StatelessWidget {
  const CheckInsPreviewView({super.key, this.role = CheckInPreviewRole.coach});
  static const routeName = '/check-ins-preview';
  final CheckInPreviewRole role;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<CheckInsCubit>()..load(role: role),
        child: role == CheckInPreviewRole.coach
            ? const CheckInCoachList()
            : const ClientPreview(),
      );
}
