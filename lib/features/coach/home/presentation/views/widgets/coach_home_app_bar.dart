import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoachHomeAppBar extends StatelessWidget {
  const CoachHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Athletica',
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          _ChatIconButton(),
        ],
      ),
    );
  }
}

class _ChatIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SvgPicture.asset(
          'assets/images/chat_icon.svg',
          width: 20.sp,
          height: 20.sp,
        ),
      ),
    );
  }
}
