import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assigned_app_bar.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assigned_content.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assigned_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignedViewBody extends StatelessWidget {
  const AssignedViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AssignedAppBar(),
        Expanded(
          child: BlocBuilder<AssignedCubit, AssignedState>(
            builder: (context, state) {
              if (state is AssignedLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AssignedError) {
                return AssignedErrorView(message: state.message);
              }

              if (state is AssignedLoaded) {
                return AssignedContent(assigned: state.assigned);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
