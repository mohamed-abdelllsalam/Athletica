import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_response_view.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientPreview extends StatelessWidget {
  const ClientPreview({super.key});
  @override
  Widget build(BuildContext context) => CheckInPage(
        title: 'Your Check-in',
        child: BlocBuilder<CheckInsCubit, CheckInsState>(
          builder: (context, state) => switch (state) {
            CheckInsLoading() =>
              const Center(child: CircularProgressIndicator()),
            CheckInsError(:final message) => StatusMessage(
                  message: message,
                  onRetry: () => context.read<CheckInsCubit>().load(),
                ),
            CheckInsReady(:final entries, :final questions) => entries.isEmpty
                ? const StatusMessage(message: 'No check-ins available.')
                : CheckInResponseView(
                    key: ValueKey(entries.first.id),
                    entry: entries.first,
                    questions: questions,
                    coachResponse: false,
                    embedded: true,
                  ),
          },
        ),
      );
}
