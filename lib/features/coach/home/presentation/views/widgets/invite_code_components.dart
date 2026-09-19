import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachInviteCodeDigit extends StatelessWidget {
  const CoachInviteCodeDigit({
    super.key,
    required this.fade,
    required this.pop,
    required this.character,
  });

  /// Eased within [0, 1] — safe for opacity and slide offset.
  final Animation<double> fade;

  /// Overshoots above 1 — only used for the scale pop.
  final Animation<double> pop;
  final String character;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: fade.drive(
          Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero),
        ),
        child: ScaleTransition(
          scale: pop.drive(Tween<double>(begin: 0.4, end: 1)),
          child: Container(
            height: 56.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.buttonColor, width: 1.5),
            ),
            child: Text(
              character,
              style: AppTextStyles.bold24(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class CoachInviteDialogButton extends StatelessWidget {
  const CoachInviteDialogButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18.sp),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.surfaceDark, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18.sp),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
    );
  }
}
