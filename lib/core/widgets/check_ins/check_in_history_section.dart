import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/errors/failures.dart';
import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/core/utils/check_in_date_format.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared by the client's overview and the coach's per-client history.
class CheckInHistorySection extends StatelessWidget {
  const CheckInHistorySection({
    super.key,
    required this.result,
    required this.onRetry,
    required this.onOpen,
    this.previousResult,
  });
  final ApiResult<List<CheckInSubmission>>? result;
  final ApiResult<List<CheckInSubmission>>? previousResult;
  final VoidCallback onRetry;
  final ValueChanged<CheckInSubmission> onOpen;

  @override
  Widget build(BuildContext context) {
    if (result case ApiError(failure: NetworkFailure())) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ConnectionErrorView(compact: true, onRetry: onRetry),
        if (previousResult is ApiSuccess<List<CheckInSubmission>>)
          CheckInHistorySection(result: previousResult, onRetry: onRetry, onOpen: onOpen),
      ]);
    }
    return _buildSection(context);
  }

  Widget _buildSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text('History', style: CheckInUi.text(16)),
          const Spacer(),
          if (result case ApiSuccess(data: final items))
            if (items.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: CheckInUi.violet.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: CheckInUi.violet.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  '${items.length} ${items.length == 1 ? 'check-in' : 'check-ins'}',
                  style: CheckInUi.text(
                    10,
                    color: const Color(0xFFC9A8FF),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
        ],
      ),
      SizedBox(height: 12.h),
      switch (result) {
        null => Padding(
          padding: EdgeInsets.symmetric(vertical: 28.h),
          child: const Center(child: CircularProgressIndicator()),
        ),
        ApiError(:final failure) => Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: CheckInUi.panel,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                failure.message,
                textAlign: TextAlign.center,
                style: CheckInUi.text(12, weight: FontWeight.w400),
              ),
              SizedBox(height: 6.h),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry history'),
              ),
            ],
          ),
        ),
        ApiSuccess(data: final items) =>
          items.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 26.h,
                  ),
                  decoration: BoxDecoration(
                    color: CheckInUi.panel,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A38F5), Color(0xFF3F42B8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.fact_check_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No submitted check-ins yet.',
                        textAlign: TextAlign.center,
                        style: CheckInUi.text(12, weight: FontWeight.w400),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'New submissions will appear here.',
                        textAlign: TextAlign.center,
                        style: CheckInUi.text(
                          11,
                          color: Colors.white70,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (final (index, item) in items.indexed)
                      Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        decoration: BoxDecoration(
                          color: CheckInUi.panel,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: CheckInUi.violet.withValues(alpha: 0.28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          leading: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF38D855),
                                  Color(0xFF1E9E4A),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${items.length - index}',
                                style: CheckInUi.text(13),
                              ),
                            ),
                          ),
                          title: Text(
                            'Completed',
                            style: CheckInUi.text(12),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_outlined,
                                      color: Colors.white70,
                                      size: 13,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        formatCheckInDate(item.submittedAt),
                                        style: CheckInUi.text(
                                          11,
                                          color: Colors.white70,
                                          weight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.answers.isEmpty
                                      ? 'Tap to view answers'
                                      : '${item.answers.length} ${item.answers.length == 1 ? 'answer' : 'answers'} • Tap to view',
                                  style: CheckInUi.text(
                                    10,
                                    color: const Color(0xFFC9A8FF),
                                    weight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            width: 30.r,
                            height: 30.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.14),
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          onTap: () => onOpen(item),
                        ),
                      ),
                  ],
                ),
      },
    ],
  );
}
