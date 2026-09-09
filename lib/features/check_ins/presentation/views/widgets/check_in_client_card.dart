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
  });
  final CheckIn entry;
  final VoidCallback onView;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) {
    final completed = entry.status == CheckInStatus.completed;
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
              const CheckInAvatar(),
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
                        color: completed
                            ? const Color(0xFF1E3B24)
                            : const Color(0xFF40300F),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Text(
                        completed ? '● Completed' : '● Pending',
                        style: CheckInUi.text(
                          8,
                          color: completed
                              ? const Color(0xFF38D855)
                              : const Color(0xFFE4A724),
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
                  Text(entry.timeLabel, style: CheckInUi.text(9)),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: 76.w,
                    child: FilledButton(
                      onPressed: onSend,
                      style: FilledButton.styleFrom(
                        backgroundColor: CheckInUi.violet,
                        minimumSize: const Size(0, 30),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      child: Text(
                        'Send',
                        style: CheckInUi.text(11, weight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: completed ? 28.h : 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (completed) ...[
                CheckInMetric('Mood', entry.mood, 'mood'),
                CheckInMetric('Sleep', entry.sleep, 'sleep'),
                CheckInMetric('Soreness', entry.soreness, 'soreness'),
                CheckInMetric('Energy', entry.energy, 'energy'),
              ] else
                Expanded(
                  child: Text('No Check-in Yet', style: CheckInUi.text(10)),
                ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 48.w,
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
                  child: Text('View', style: CheckInUi.text(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckInMetric extends StatelessWidget {
  const CheckInMetric(this.label, this.value, this.asset, {super.key});
  final String label;
  final String value;
  final String asset;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: EdgeInsets.only(right: 3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CheckInUi.text(9)),
          SizedBox(height: 7.h),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 3.w,
            children: [
              CheckInAsset(asset, size: 17),
              Text(value, style: CheckInUi.text(9)),
            ],
          ),
        ],
      ),
    ),
  );
}
