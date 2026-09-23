import 'package:athletica/core/utils/check_in_date_format.dart';
import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckInClientCard extends StatelessWidget {
  const CheckInClientCard({
    super.key,
    required this.entry,
    required this.onView,
    required this.onSend,
    this.sending = false,
  });
  final CheckIn entry;
  final VoidCallback onView;
  final VoidCallback onSend;
  final bool sending;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: CheckInUi.panel,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckInAvatar(imageUrl: entry.clientPhotoUrl),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.clientName, style: CheckInUi.text(11)),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: switch (entry.status) {
                          CheckInStatus.completed => const Color(0xFF1E3B24),
                          CheckInStatus.pending => const Color(0xFF40300F),
                          CheckInStatus.notAssigned => const Color(0xFF2A2E35),
                        },
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Text(
                        switch (entry.status) {
                          CheckInStatus.completed => '● Completed',
                          CheckInStatus.pending => '● Pending',
                          CheckInStatus.notAssigned => '● Not assigned',
                        },
                        style: CheckInUi.text(
                          8,
                          color: switch (entry.status) {
                            CheckInStatus.completed => const Color(0xFF38D855),
                            CheckInStatus.pending => const Color(0xFFE4A724),
                            CheckInStatus.notAssigned => const Color(
                              0xFF9AA0A6,
                            ),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (entry.submittedAt != null) ...[
                    Text('Last submitted', style: CheckInUi.text(9)),
                    Text(
                      formatCheckInDate(entry.submittedAt),
                      style: CheckInUi.text(9),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: 76.w,
                    child: FilledButton(
                      onPressed: sending ? null : onSend,
                      style: FilledButton.styleFrom(
                        backgroundColor: CheckInUi.violet,
                        minimumSize: const Size(0, 30),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      child: Text(
                        sending ? 'Sending…' : 'Send',
                        style: CheckInUi.text(11, weight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 72.w,
                child: FilledButton(
                  onPressed: onView,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2588F7),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  child: Text('History', style: CheckInUi.text(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
