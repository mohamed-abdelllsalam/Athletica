import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/widgets/check_ins/check_in_history_section.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/cubits/check_in_history_cubit.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_submission_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInHistoryView extends StatelessWidget {
  const CheckInHistoryView({
    super.key,
    required this.coachClientId,
    required this.clientName,
    this.clientPhotoUrl,
  });
  final String coachClientId;
  final String clientName;
  final String? clientPhotoUrl;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<CheckInHistoryCubit>()..load(coachClientId),
    child: CheckInPage(
      title: '$clientName - History',
      child:
          BlocBuilder<CheckInHistoryCubit, ApiResult<List<CheckInSubmission>>?>(
            builder: (context, state) {
              final cubit = context.read<CheckInHistoryCubit>();
              final count = state is ApiSuccess<List<CheckInSubmission>>
                  ? state.data.length
                  : null;
              return RefreshIndicator(
                onRefresh: () => cubit.load(coachClientId),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B1030), Color(0xFF0E1118)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: CheckInUi.violet.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CheckInUi.violet.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                            child: CheckInAvatar(
                              size: 52,
                              imageUrl: clientPhotoUrl,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(clientName, style: CheckInUi.text(15)),
                                SizedBox(height: 4.h),
                                Text(
                                  count == null
                                      ? 'Check-in history'
                                      : count == 0
                                      ? 'No check-ins yet'
                                      : '$count ${count == 1 ? 'check-in' : 'check-ins'} submitted',
                                  style: CheckInUi.text(
                                    11,
                                    color: const Color(0xFFC9A8FF),
                                    weight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CheckInUi.violet.withValues(alpha: 0.16),
                            ),
                            child: const Icon(
                              Icons.history_outlined,
                              color: Color(0xFFC9A8FF),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CheckInHistorySection(
                      result: state,
                      previousResult: cubit.previousResult,
                      onRetry: () => cubit.load(coachClientId),
                      onOpen: (submission) async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckInSubmissionView(
                              coachClientId: coachClientId,
                              submissionId: submission.id,
                            ),
                          ),
                        );
                        if (!cubit.isClosed) await cubit.load(coachClientId);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    ),
  );
}
