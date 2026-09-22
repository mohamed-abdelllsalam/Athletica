import 'package:athletica/core/widgets/check_ins/check_in_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
