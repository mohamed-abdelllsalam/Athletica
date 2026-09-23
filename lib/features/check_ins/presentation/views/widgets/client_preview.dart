import 'package:athletica/core/widgets/check_ins/check_in_history_section.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_ins_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_response_view.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_submission_view.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientPreview extends StatelessWidget {
  const ClientPreview({super.key});

  @override
  Widget build(BuildContext context) => CheckInPage(
    title: 'Your Check-in',
    child: BlocBuilder<CheckInsCubit, CheckInsState>(
      builder: (context, state) {
        final cubit = context.read<CheckInsCubit>();
        return switch (state) {
          CheckInsLoading() => const Center(child: CircularProgressIndicator()),
          CheckInsError(:final message) => StatusMessage(
            message: message,
            onRetry: cubit.refresh,
          ),
          CheckInsReady() => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text('Current check-in', style: CheckInUi.text(16)),
                const SizedBox(height: 8),
                if (state.hasPending) ...[
                  Text(
                    'Pending',
                    style: CheckInUi.text(14, color: const Color(0xFFE4A724)),
                  ),
                  CheckInResponseView(
                    key: ValueKey(state.questions.map((q) => q.id).join(',')),
                    entry: CheckIn(
                      id: 'pending',
                      clientName: '',
                      status: CheckInStatus.pending,
                    ),
                    questions: state.questions,
                    coachResponse: false,
                    embedded: true,
                  ),
                ] else if (state.clientStatus != null) ...[
                  Text(
                    state.clientStatus == CheckInStatus.completed
                        ? 'Completed'
                        : 'Not assigned',
                    style: CheckInUi.text(14),
                  ),
                  Text(
                    'Waiting for your coach to assign a new check-in.',
                    style: CheckInUi.text(12),
                  ),
                ] else
                  Text('No pending check-in.', style: CheckInUi.text(12)),
                const SizedBox(height: 24),
                CheckInHistorySection(
                  result: state.history,
                  onRetry: cubit.reloadClientHistory,
                  onOpen: (submission) async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CheckInSubmissionView(submissionId: submission.id),
                      ),
                    );
                    if (!cubit.isClosed) await cubit.refresh();
                  },
                ),
              ],
            ),
          ),
        };
      },
    ),
  );
}
