import 'package:athletica/core/utils/check_in_date_format.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Historical snapshots are independent of today's form and deleted questions.
class CheckInSubmissionAnswers extends StatelessWidget {
  const CheckInSubmissionAnswers({super.key, required this.submission});
  final CheckInSubmission submission;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF14231A), Color(0xFF0E1118)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF38D855).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38D855).withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF38D855),
                size: 24,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (submission.clientName.isNotEmpty)
                    Text(submission.clientName, style: CheckInUi.text(15)),
                  Text(
                    'Completed',
                    style: CheckInUi.text(
                      13,
                      color: const Color(0xFF38D855),
                    ),
                  ),
                  SizedBox(height: 2.h),
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
                          formatCheckInDate(submission.submittedAt),
                          style: CheckInUi.text(
                            11,
                            color: Colors.white70,
                            weight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 16.h),
      Text(
        '${submission.answers.length} ${submission.answers.length == 1 ? 'answer' : 'answers'}',
        style: CheckInUi.text(
          11,
          color: const Color(0xFFC9A8FF),
          weight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 10.h),
      if (submission.answers.isEmpty)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: CheckInUi.panel,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            'No answers in this submission.',
            style: CheckInUi.text(12, weight: FontWeight.w400),
          ),
        ),
      for (final (index, answer) in submission.answers.indexed)
        Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: CheckInUi.panel,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.r,
                    height: 24.r,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: CheckInUi.number,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: CheckInUi.text(11, color: CheckInUi.numberText),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      answer.snapshotQuestion.isEmpty
                          ? 'Question'
                          : answer.snapshotQuestion,
                      style: CheckInUi.text(13),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (answer.snapshotType == 'IMAGE' &&
                  answer.answerValue.startsWith('https://'))
                GestureDetector(
                  onTap: () => _showFullPhoto(
                    context,
                    answer.answerValue,
                    answer.snapshotQuestion,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 400),
                      color: Colors.black,
                      child: Image.network(
                        answer.answerValue,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        semanticLabel: answer.snapshotQuestion,
                        errorBuilder: (_, error, stack) => Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Text(
                            'Photo unavailable',
                            style: CheckInUi.text(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 9.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    answer.answerValue.isEmpty
                        ? 'No answer'
                        : answer.answerValue,
                    style: CheckInUi.text(12, weight: FontWeight.w400),
                  ),
                ),
            ],
          ),
        ),
    ],
  );

  void _showFullPhoto(BuildContext context, String url, String label) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(16.r),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                semanticLabel: label,
                errorBuilder: (_, _, _) => Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Text(
                    'Photo unavailable',
                    style: CheckInUi.text(12),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: IconButton(
                tooltip: 'Close',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
