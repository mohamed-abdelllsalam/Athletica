import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/widgets/check_ins/check_in_submission_answers.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_in_submission_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckInSubmissionView extends StatelessWidget {
  const CheckInSubmissionView({
    super.key,
    this.coachClientId,
    required this.submissionId,
  });
  final String? coachClientId;
  final String submissionId;

  void _load(CheckInSubmissionCubit cubit) =>
      cubit.load(coachClientId: coachClientId, submissionId: submissionId);

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = sl<CheckInSubmissionCubit>();
      _load(cubit);
      return cubit;
    },
    child: CheckInPage(
      title: 'Check-in Answers',
      child: BlocBuilder<CheckInSubmissionCubit, ApiResult<CheckInSubmission>?>(
        builder: (context, state) => switch (state) {
          null => const Center(child: CircularProgressIndicator()),
          ApiError(failure: NetworkFailure()) => Builder(
            builder: (context) {
              final previous = context
                  .read<CheckInSubmissionCubit>()
                  .previousResult;
              final hasPrevious = previous is ApiSuccess<CheckInSubmission>;
              return Column(
                children: [
                  ConnectionErrorView(
                    compact: hasPrevious,
                    onRetry: () =>
                        _load(context.read<CheckInSubmissionCubit>()),
                  ),
                  if (hasPrevious)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: CheckInSubmissionAnswers(
                          submission: previous.data,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          ApiError(:final failure) => StatusMessage(
            message: failure.message,
            onRetry: () => _load(context.read<CheckInSubmissionCubit>()),
          ),
          ApiSuccess(:final data) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CheckInSubmissionAnswers(submission: data),
          ),
        },
      ),
    ),
  );
}
